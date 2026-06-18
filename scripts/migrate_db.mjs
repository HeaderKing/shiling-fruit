// Supabase 数据库迁移脚本
import pg from 'pg';

const { Client } = pg;

const client = new Client({
  connectionString: 'postgresql://postgres:zt%40ZT0901..@db.qbfbwugomznmbmhmdgtz.supabase.co:5432/postgres',
  ssl: { rejectUnauthorized: false },
});

await client.connect();
console.log('✅ 数据库连接成功');

const sql = `
CREATE TABLE IF NOT EXISTS fruits (
  id            TEXT PRIMARY KEY,
  name          TEXT NOT NULL,
  english_name  TEXT DEFAULT '',
  emoji         TEXT DEFAULT '',
  image         TEXT DEFAULT '',
  color_hex     TEXT DEFAULT '#CCCCCC',
  brix_min      REAL DEFAULT 0,
  brix_max      REAL DEFAULT 0,
  calorie       INT DEFAULT 0,
  tcm_nature    TEXT DEFAULT '平',
  alias_json         TEXT DEFAULT '[]',
  vitamins_json      TEXT DEFAULT '{}',
  minerals_json      TEXT DEFAULT '{}',
  benefits_json      TEXT DEFAULT '[]',
  contraindications_json TEXT DEFAULT '[]',
  origins_json       TEXT DEFAULT '[]',
  peak_season        TEXT DEFAULT '',
  picking_tips       TEXT DEFAULT '',
  storage_tips       TEXT DEFAULT '',
  best_eat_method    TEXT DEFAULT '',
  variety_json       TEXT DEFAULT '[]',
  grade_std          TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname    TEXT DEFAULT '',
  avatar_url  TEXT DEFAULT '',
  bio         TEXT DEFAULT '',
  city_id     TEXT DEFAULT '',
  level       INT DEFAULT 1,
  score       INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, nickname)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'nickname', '用户' || substr(NEW.id::text, 1, 6)));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TABLE IF NOT EXISTS posts (
  id           BIGSERIAL PRIMARY KEY,
  user_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type         TEXT NOT NULL DEFAULT 'share'
               CHECK (type IN ('share','guide','experience','question')),
  title        TEXT NOT NULL DEFAULT '',
  content      TEXT DEFAULT '',
  fruit_id     TEXT REFERENCES fruits(id) ON DELETE SET NULL,
  city_id      TEXT DEFAULT '',
  tags         TEXT[] DEFAULT '{}',
  status       TEXT NOT NULL DEFAULT 'pending'
               CHECK (status IN ('pending','approved','rejected')),
  like_count   INT DEFAULT 0,
  comment_count INT DEFAULT 0,
  bookmark_count INT DEFAULT 0,
  view_count   INT DEFAULT 0,
  created_at   TIMESTAMPTZ DEFAULT now(),
  updated_at   TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_status ON posts(status);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);

CREATE TABLE IF NOT EXISTS post_images (
  id          BIGSERIAL PRIMARY KEY,
  post_id     BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  url         TEXT NOT NULL,
  sort_order  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_post_images_post_id ON post_images(post_id);

CREATE TABLE IF NOT EXISTS comments (
  id          BIGSERIAL PRIMARY KEY,
  post_id     BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id   BIGINT REFERENCES comments(id) ON DELETE CASCADE,
  content     TEXT NOT NULL,
  like_count  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);

CREATE TABLE IF NOT EXISTS likes (
  id          BIGSERIAL PRIMARY KEY,
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  target_type TEXT NOT NULL CHECK (target_type IN ('post','comment')),
  target_id   BIGINT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, target_type, target_id)
);

CREATE INDEX IF NOT EXISTS idx_likes_target ON likes(target_type, target_id);

CREATE TABLE IF NOT EXISTS bookmarks (
  id          BIGSERIAL PRIMARY KEY,
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  post_id     BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, post_id)
);

CREATE OR REPLACE FUNCTION increment_like_count(post_id_ BIGINT)
RETURNS void LANGUAGE SQL AS $$
  UPDATE posts SET like_count = like_count + 1 WHERE id = post_id_;
$$;

CREATE OR REPLACE FUNCTION decrement_like_count(post_id_ BIGINT)
RETURNS void LANGUAGE SQL AS $$
  UPDATE posts SET like_count = GREATEST(0, like_count - 1) WHERE id = post_id_;
$$;
`;

try {
  await client.query(sql);
  console.log('✅ 所有表创建成功');
} catch (e) {
  console.error('❌ 建表失败:', e.message);
}

await client.end();