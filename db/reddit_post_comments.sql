CREATE TABLE "reddit_post_comments" (
  "id"                INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  "reddit_id"         INTEGER NOT NULL,
  "reddit_post_id"    INTEGER NOT NULL,
  "title"             varchar NOT NULL,
  "author"            varchar,
  "content"           varchar,
  "up_votes"          integer,
  "down_votes"        integer
);