drop table if exists mission_plan;
create table mission_plan (
        id serial primary key,
        the_date date,
        title varchar(100),
        description text
);
