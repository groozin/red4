create schema if not exists import;
drop table if exists import.master_plan;
create table import.master_plan(
        start_time_utc text,
        duration text,
        date text,
        team text,
        spass_type text,
        target text,
        request_name text,
        library_definition text,
        title text,
        description text
);
COPY import.master_plan FROM '/mnt/d/repo/red4/data/master_plan.csv' WITH DELIMITER ',' HEADER CSV;
drop table if exists teams cascade;
select distinct(team)
as description
into teams
from import.master_plan;

alter table teams
add id serial primary key;

drop table if exists spass_types cascade;
select distinct(spass_type)
as description
into spass_types
from import.master_plan;

alter table spass_types
add id serial primary key;

drop table if exists targets cascade;
select distinct(target)
as description
into targets
from import.master_plan;

alter table targets
add id serial primary key;

drop table if exists requests cascade;
select distinct(request_name)
as description
into requests
from import.master_plan;

alter table requests
add id serial primary key;

drop table if exists event_types cascade;
select distinct(library_definition)
as description
into event_types
from import.master_plan;

alter table event_types
add id serial primary key;

drop table if exists events;
create table events (
        id serial primary key,
        time_stamp timestamptz not null,
        title varchar(500),
        description text,
        event_type_id int references event_types(id),
        spass_type_id int references spass_types(id),
        target_id int references targets(id),
        team_id int references teams(id),
        request_id int references requests(id)
);

insert into events (
        time_stamp,
        title,
        description,
        event_type_id,
        spass_type_id,
        target_id,
        team_id,
        request_id
)
select 
        import.master_plan.start_time_utc::timestamp,
        import.master_plan.title,
        import.master_plan.description,
        event_types.id as event_type_id,
        spass_types.id as spass_type_id,
        targets.id as target_id,
        teams.id as team_id,
        requests.id as request_id
from import.master_plan
left join event_types
        on event_types.description = import.master_plan.library_definition
left join spass_types 
        on spass_types.description = import.master_plan.spass_type
left join targets 
        on targets.description = import.master_plan.target
left join teams 
        on teams.description = import.master_plan.team
left join requests 
        on requests.description = import.master_plan.request_name;
