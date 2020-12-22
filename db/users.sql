CREATE TABLE "users" (
  "id"                      INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  "username"                varchar NOT NULL,
  "email_address"           varchar NOT NULL,
  "password"                varchar NOT NULL,
  "password_confirmation"   varchar NOT NULL,
  "admin"                   BOOLEAN DEFAULT false
);
