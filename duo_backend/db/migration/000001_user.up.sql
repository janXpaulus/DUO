ALTER DATABASE duo SET TIMEZONE TO 'UTC';
CREATE ROLE duo_user_role;
GRANT duo_user_role TO duo_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO duo_user_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO duo_user_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO duo_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO duo_user;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE USERSTATUS AS ENUM ('online', 'inLobby', 'inGame', 'offline');

CREATE TABLE IF NOT EXISTS duouser (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(255) NOT NULL,
    user_status USERSTATUS NOT NULL DEFAULT 'offline',
    score INT NOT NULL DEFAULT 0,
    public_key TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS user_login (
    user_uuid UUID NOT NULL UNIQUE,
    challenge VARCHAR(255) NOT NULL,
    login_time TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE user_login ADD CONSTRAINT fk_user_id FOREIGN KEY (user_uuid) REFERENCES duouser(uuid) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS user_login_time_idx ON user_login (login_time);

