// config.js
// Cấu hình Supabase
(function() {
    if (typeof window.supabase === 'undefined') {
        console.error('Lỗi: Supabase chưa được import. Vui lòng import Supabase CDN trước config.js');
        return;
    }

    // ⚠️ THAY URL VÀ KEY BẰNG THÔNG TIN PROJECT RUNG CHUÔNG CỦA BẠN
    // Vào: Supabase Dashboard → Settings → API
    window.SUPABASE_URL = "https://bdzrulrapcfemgicctye.supabase.co";
    window.SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkenJ1bHJhcGNmZW1naWNjdHllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzMDU5MjAsImV4cCI6MjA4ODg4MTkyMH0.RMcH3Q369J_gnCft1Mg53EYj3tiol09mm_A3N0CJGPw";

    // Khởi tạo Supabase client
    window.supabase = window.supabase.createClient(window.SUPABASE_URL, window.SUPABASE_KEY);

    console.log('✅ Supabase đã được khởi tạo thành công');
})();
