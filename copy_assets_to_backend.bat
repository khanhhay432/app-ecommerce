@echo off
echo ========================================
echo Copy Images from Assets to Backend
echo ========================================
echo.

echo Creating uploads directory if not exists...
if not exist "backend\uploads" mkdir "backend\uploads"
echo.

echo Copying images from assets\img to backend\uploads...
xcopy "assets\img\*.*" "backend\uploads\" /Y /I
echo.

echo ========================================
echo Done! Images copied successfully.
echo ========================================
echo.
echo Next steps:
echo 1. Run the SQL script: database\update_images_to_backend_urls.sql
echo 2. Restart backend server
echo 3. Images will be available at: http://localhost:8080/uploads/filename.jpg
echo.

pause
