-- 1. XOÁ BẢNG CŨ
DROP TABLE IF EXISTS player_sessions CASCADE;
DROP TABLE IF EXISTS game_state CASCADE;

-- 2. TẠO BẢNG game_state
CREATE TABLE game_state (
    id                     TEXT PRIMARY KEY,
    current_question_index INTEGER DEFAULT 0,
    questions              JSONB DEFAULT '[]',
    players                JSONB DEFAULT '{}',
    scores                 JSONB DEFAULT '{}',
    current_ringer         TEXT DEFAULT NULL,
    game_started           BOOLEAN DEFAULT false,
    can_ring               BOOLEAN DEFAULT false,
    round_active           BOOLEAN DEFAULT false,
    max_players            INTEGER DEFAULT 6,
    question_shown         BOOLEAN DEFAULT false,
    player_answer          INTEGER DEFAULT NULL,
    updated_at             TIMESTAMPTZ DEFAULT NOW()
);

-- 3. TẠO BẢNG player_sessions
CREATE TABLE player_sessions (
    player_id    TEXT PRIMARY KEY,
    game_id      TEXT NOT NULL,
    player_name  TEXT NOT NULL,
    logged_in_at TIMESTAMPTZ DEFAULT NOW(),
    last_seen    TIMESTAMPTZ DEFAULT NOW()
);

-- 4. DỮ LIỆU MẶC ĐỊNH
INSERT INTO game_state (
    id, current_question_index, questions, players, scores,
    current_ringer, game_started, can_ring, round_active,
    max_players, question_shown, player_answer
) VALUES (
    'current_game', 0, '[]', '{}', '{}',
    NULL, false, false, false,
    6, false, NULL
);

-- 5. BẬT RLS (giống AppThi - cách đúng)
ALTER TABLE game_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_sessions ENABLE ROW LEVEL SECURITY;

-- 6. TẠO POLICY cho phép tất cả (giống AppThi)
DROP POLICY IF EXISTS "Cho phép tất cả game_state" ON game_state;
CREATE POLICY "Cho phép tất cả game_state" ON game_state FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Cho phép tất cả player_sessions" ON player_sessions;
CREATE POLICY "Cho phép tất cả player_sessions" ON player_sessions FOR ALL USING (true) WITH CHECK (true);

-- 7. GRANT quyền cho anon và authenticated
GRANT ALL ON game_state TO anon, authenticated;
GRANT ALL ON player_sessions TO anon, authenticated;

-- 8. TRIGGER tự cập nhật updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_game_state_updated_at ON game_state;
CREATE TRIGGER trg_game_state_updated_at
    BEFORE UPDATE ON game_state
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 9. KÍCH HOẠT REALTIME (bọc an toàn)
DO $$
BEGIN
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE game_state;
    EXCEPTION WHEN others THEN NULL;
    END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE player_sessions;
    EXCEPTION WHEN others THEN NULL;
    END;
END $$;

-- 10. INDEX
CREATE INDEX idx_player_sessions_game_id ON player_sessions(game_id);
CREATE INDEX idx_player_sessions_last_seen ON player_sessions(last_seen);

SELECT '✅ RungChuong setup thành công!' as message;
