CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE projects
(
    id         uuid        NOT NULL DEFAULT uuid_generate_v4(),
    tenant_id  uuid        NOT NULL,
    name       varchar     NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

CREATE TABLE errors
(
    tenant_id  uuid        NOT NULL,
    project_id uuid        NOT NULL,
    trace_id   uuid        NOT NULL,
    message    varchar     NOT NULL,
    stack_trace varchar,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (trace_id),
    CONSTRAINT fk_project_id
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
);

CREATE TABLE traces
(
    id             uuid        NOT NULL DEFAULT uuid_generate_v4(),
    tenant_id      uuid        NOT NULL,
    trace_id       uuid        NOT NULL,
    correlation_id varchar     NOT NULL,
    data           varchar     NOT NULL,
    meta           jsonb,
    operation_type varchar,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id),
    CONSTRAINT fk_trace_id
        FOREIGN KEY (trace_id) REFERENCES errors (trace_id) ON DELETE CASCADE
);
