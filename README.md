# mehrdad.ir — cPanel Git Deploy (بدون SSH)

این ریپو فقط برای استقرار روی cPanel **بدون SSH/Terminal** است.
آرتیفکت production (بدون دیتابیس و بدون هرگونه secret) به دو قطعه شکسته شده
(نسخهٔ 2026-09-05 — شامل real routes، لایه AI-SEO، فیکس‌های امنیتی round-3 و هیروی خدمات)
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
   - دیتابیس روی **Turso ابری** است — فایلی لازم نیست (هاست خالی مشکلی ندارد)
3. cPanel → **Setup Node.js App** → Create Application:
   | فیلد | مقدار |
   |---|---|
   | Node.js version | 20.20.2 (یا نزدیک‌ترین 20.x/22.x موجود) |
   | Application mode | Production |
   | Application root | `mehrdad-app` |
   | Application URL | mehrdad.ir (یا اول ساب‌دامین staging) |
   | Startup file | `server.js` |
4. Environment Variables — همان صفحه، ۶ بار **Add Variable**:

   | Name | Value |
   |---|---|
   | `TURSO_DATABASE_URL` | `libsql://mehrdad-goolro.aws-ap-south-1.turso.io` |
   | `TURSO_AUTH_TOKEN` | توکن Turso (از هاست قبلی کپی، یا `turso db tokens create mehrdad`) |
   | `ADMIN_PASSWORD` | همان رمز بلند ادمین |
   | `SITE_ORIGIN` | `https://mehrdad.ir` |
   | `NODE_ENV` | `production` |
   | `HOSTNAME` | `0.0.0.0` |

   در حالت Turso نیازی به `DATABASE_URL` نیست. بعد از ذخیره → **Restart**.
5. تست: `/api/posts` باید JSON بدهد (۸۲ پست).

## آپدیت‌های بعدی

Commit جدید روی این ریپو → در cPanel دکمهٔ **Update from Remote** → سپس
**Deploy**. دیتابیس و `data/` هرگز دست نمی‌خورند.
