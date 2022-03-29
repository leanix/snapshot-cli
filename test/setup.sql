CREATE SCHEMA ws_00000000_0000_0000_0000_000000000000;
ALTER SCHEMA ws_00000000_0000_0000_0000_000000000000 OWNER TO postgres;

SET search_path TO 'ws_00000000_0000_0000_0000_000000000000';
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" with schema ws_00000000_0000_0000_0000_000000000000;
-- auto-generated definition
create table factsheets
(
    id           varchar(100) not null primary key,
    workspace_id uuid                            not null,
    status       varchar(20)
);

alter table factsheets
    owner to postgres;

insert into factsheets (id, workspace_id, status)
values ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'ACTIVE');


create table subscriptions
(
    id           varchar(100) not null primary key,
    workspace_id uuid                            not null,
    status       varchar(20)
);

alter table subscriptions
    owner to postgres;

insert into subscriptions (id, workspace_id, status)
values ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000004', 'ACTIVE');
