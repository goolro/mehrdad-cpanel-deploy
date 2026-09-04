# mehrdad.ir — cPanel Git Deploy (بدون SSH)

این ریپو فقط برای استقرار روی cPanel **بدون SSH/Terminal** است.
آرتیفکت production (بدون دیتابیس و بدون هرگونه secret) به دو قطعه شکسته شده
چون گیت‌هاب فایل بالای ۱۰۰MB قبول نمی‌کند.

## راه‌اندازی در cPanel (یک‌بار)

1. cPanel → **Git™ Version Control** → **Create**:
   - Clone URL: `https://github.com/goolro/mehrdad-cpanel-deploy.git`
   - Repository name: `mehrdad-deploy`
   - (مسیر پیش‌فرض `~/repositories/mehrdad-deploy` بماند)
2. بعد از ایجاد، روی **Manage** کلیک کنید → تب **Deploy** → دکمهٔ
   **Deploy from Existing Repository** (یا Head Commit → Deploy)
   → اسکریپت `deploy.sh` خودکار اجرا می‌شود:
   - آرتیفکت را بازچینی و checksum می‌گیرد
   - در `~/mehrdad-app` استخراج می‌کند
   - `data/production.db` را **فقط بار اول** می‌سازد
3. cPanel → **Setup Node.js App** → Create Application:
   | فیلد | مقدار |
   |---|---|
   | Node.js version | 20.20.2 |
   | Application mode | Production |
   | Application root | `mehrdad-app` |
   | Application URL | آدرس staging (مثلاً ساب‌دامین موقت) |
   | Startup file | `server.js` |
4. Environment Variables (همان صفحه):
   - `DATABASE_URL` = `file:/home/motorpum/mehrdad-app/data/production.db`
   - `ADMIN_PASSWORD` = یک رمز بلند تصادفی
   - `NODE_ENV` = `production`
   - `HOSTNAME` = `0.0.0.0`
5. **Restart** → آدرس Application URL را باز کنید → `/api/posts` باید JSON بدهد.

## آپدیت‌های بعدی

Commit جدید روی این ریپو → در cPanel دکمهٔ **Update from Remote** → سپس
**Deploy**. دیتابیس و `data/` هرگز دست نمی‌خورند.
