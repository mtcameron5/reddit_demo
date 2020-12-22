CREATE TABLE "reddit_posts" (
  "id"            INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  "reddit_id"     INTEGER NOT NULL,
  "reddit_title"  varchar NOT NULL,
  "title"         varchar NOT NULL,
  "author"        varchar NOT NULL,
  "content"       varchar NOT NULL,
  "up_votes"      integer,
  "down_votes"    integer
);