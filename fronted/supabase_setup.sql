-- 创建生成图像表
CREATE TABLE IF NOT EXISTS generated_images (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    prompt TEXT NOT NULL,
    image_url TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_generated_images_user_id ON generated_images(user_id);
CREATE INDEX IF NOT EXISTS idx_generated_images_created_at ON generated_images(created_at DESC);

-- 启用行级安全策略 (RLS)
ALTER TABLE generated_images ENABLE ROW LEVEL SECURITY;

-- 创建策略：用户只能查看自己的图像
DROP POLICY IF EXISTS "Users can view own images" ON generated_images;
CREATE POLICY "Users can view own images" ON generated_images
    FOR SELECT USING (auth.uid() = user_id);

-- 创建策略：用户只能插入自己的图像
DROP POLICY IF EXISTS "Users can insert own images" ON generated_images;
CREATE POLICY "Users can insert own images" ON generated_images
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 创建策略：用户只能删除自己的图像
DROP POLICY IF EXISTS "Users can delete own images" ON generated_images;
CREATE POLICY "Users can delete own images" ON generated_images
    FOR DELETE USING (auth.uid() = user_id);

-- 创建策略：允许匿名用户查看所有图像（用于公共画廊）
DROP POLICY IF EXISTS "Allow anonymous to view all images" ON generated_images;
CREATE POLICY "Allow anonymous to view all images" ON generated_images
    FOR SELECT USING (true);

-- 创建存储桶策略
INSERT INTO storage.buckets (id, name, public) 
VALUES ('ai-images', 'ai-images', true)
ON CONFLICT (id) DO NOTHING;

-- 创建存储策略：允许认证用户上传图像
DROP POLICY IF EXISTS "Allow authenticated users to upload images" ON storage.objects;
CREATE POLICY "Allow authenticated users to upload images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'ai-images' AND auth.role() = 'authenticated');

-- 创建存储策略：允许所有人查看图像
DROP POLICY IF EXISTS "Allow public to view images" ON storage.objects;
CREATE POLICY "Allow public to view images" ON storage.objects
    FOR SELECT USING (bucket_id = 'ai-images');

-- 创建存储策略：允许用户删除自己的图像
DROP POLICY IF EXISTS "Allow users to delete own images" ON storage.objects;
CREATE POLICY "Allow users to delete own images" ON storage.objects
    FOR DELETE USING (bucket_id = 'ai-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- 用户资料和订阅
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- 创建用户资料表
CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    updated_at TIMESTAMP WITH TIME ZONE,
    subscription_level TEXT DEFAULT 'free',
    credits INT DEFAULT 10
);

-- 设置行级安全
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- 创建一个函数来处理新用户注册
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, subscription_level, credits)
  VALUES (new.id, 'free', 10);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 创建一个触发器，在 auth.users 表有新纪录时调用函数
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 创建订阅历史表 (未来使用)
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    level TEXT NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    end_date TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'active', -- active, expired, cancelled
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own subscriptions" ON subscriptions;
CREATE POLICY "Users can view own subscriptions" ON subscriptions FOR SELECT USING (auth.uid() = user_id);