# Start
You need to start **postgres** every time you start **bash**. Please use:

    sudo service postgresql start

Expect to see something like:

    Starting PostgreSQL 10 database server
    
, when succesfully started.

## Connect to enceladus db
Run **psql** client:
    
    psql

By default it tries to connect to db with the name of the user, so for user *groozin* it looks for db name *groozin* and fails if cannot find.

    psql: FATAL:  database "groozin" does not exist

To connect to enceladus db use the follwing:

    psql enceladus

If correct you will see this:

    psql (10.1)
    Type "help" for help.

    enceladus=#

Run *\conninfo* to check connection parameters:
    
    enceladus=# \conninfo
    You are connected to database "enceladus" as user "groozin" via socket in "/var/run/postgresql" at port "5432".

Ok we are there.

## Look around
Start with listing tables and schemas using *\dt* for tables and *\dn* for shemas.

List of shemas:

    enceladus=# \dn
    List of schemas
    Name  |  Owner
    --------+----------
    import | groozin
    public | postgres
    (2 rows)

List of tables:

    enceladus=# \dt               
    List of relations              
    Schema |     Name     | Type  |  Owner    
    --------+--------------+-------+---------  
    public | event_types  | table | groozin   
    public | events       | table | groozin   
    public | mission_plan | table | groozin   
    public | requests     | table | groozin   
    public | spass_types  | table | groozin   
    public | targets      | table | groozin   
    public | teams        | table | groozin   
    (7 rows)                                   

There are 2 schemas *public* (which is default) and *import* that is custom created. But only tables from *public* are listed. This is because of *search_path* runtime variable. It contains *ordered* list of schemas to look into when performing any query/operation without direct schema inclusion.

    enceladus=# show search_path;
    search_path
    -----------------
    "$user", public
    (1 row)

> **Note:** *show* displays contents of the runtime variable requested (to display all variables use *show all*). 

Only 2 schemas are part of this lookup: username (will be *groozin* in this case) and public (default). We need to add *import* at the ens so it is included when subsequent queries are made.

    enceladus=# set search_path to "$user",public,import;
    SET
    
    enceladus=# show search_path;
    search_path
    -------------------------
    "$user", public, import
    (1 row)

Let's re run *\dt*.
    
    enceladus=# \dt                                 
    List of relations                   
    Schema |     Name     | Type  |  Owner         
    --------+--------------+-------+---------       
    import | master_plan  | table | groozin        
    public | event_types  | table | groozin        
    public | events       | table | groozin        
    public | mission_plan | table | groozin        
    public | requests     | table | groozin        
    public | spass_types  | table | groozin        
    public | targets      | table | groozin        
    public | teams        | table | groozin        
    (8 rows)                                        
    
Now *import* schema is included with one additional db.

## Useful hints

To list all realations, not only tables from db use *\d*.

    enceladus=# \d
    List of relations
    Schema |        Name         |   Type   |  Owner
    --------+---------------------+----------+---------
    import | master_plan         | table    | groozin
    public | event_types         | table    | groozin
    public | event_types_id_seq  | sequence | groozin
    public | events              | table    | groozin
    public | events_id_seq       | sequence | groozin
    public | mission_plan        | table    | groozin
    public | mission_plan_id_seq | sequence | groozin
    public | requests            | table    | groozin
    public | requests_id_seq     | sequence | groozin
    public | spass_types         | table    | groozin
    public | spass_types_id_seq  | sequence | groozin
    public | targets             | table    | groozin
    public | targets_id_seq      | sequence | groozin
    public | teams               | table    | groozin
    public | teams_id_seq        | sequence | groozin
    (15 rows)

To list columns from db use *\d dbname*.
    
    enceladus=# \d events
    Table "public.events"
        Column     |           Type           | Collation | Nullable |              Default
    ---------------+--------------------------+-----------+----------+------------------------------------
    id            | integer                  |           | not null | nextval('events_id_seq'::regclass)
    time_stamp    | timestamp with time zone |           | not null |
    title         | character varying(500)   |           |          |
    description   | text                     |           |          |
    event_type_id | integer                  |           |          |
    spass_type_id | integer                  |           |          |
    target_id     | integer                  |           |          |
    team_id       | integer                  |           |          |
    request_id    | integer                  |           |          |
    Indexes:
        "events_pkey" PRIMARY KEY, btree (id)
    Foreign-key constraints:
        "events_event_type_id_fkey" FOREIGN KEY (event_type_id) REFERENCES event_types(id)
        "events_request_id_fkey" FOREIGN KEY (request_id) REFERENCES requests(id)
        "events_spass_type_id_fkey" FOREIGN KEY (spass_type_id) REFERENCES spass_types(id)
        "events_target_id_fkey" FOREIGN KEY (target_id) REFERENCES targets(id)
        "events_team_id_fkey" FOREIGN KEY (team_id) REFERENCES teams(id)

