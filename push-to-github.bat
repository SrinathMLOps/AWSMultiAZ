@echo off
echo ========================================
echo AWS Multi-AZ Project - Git Setup
echo ========================================
echo.

echo Step 1: Initializing Git repository...
git init

echo.
echo Step 2: Adding all files...
git add .

echo.
echo Step 3: Creating initial commit...
git commit -m "Initial commit: AWS Multi-AZ High Availability POC with complete documentation and demo GIF"

echo.
echo Step 4: Renaming branch to main...
git branch -M main

echo.
echo Step 5: Adding remote repository...
git remote add origin https://github.com/SrinathMLOps/AWSMultiAZ.git

echo.
echo Step 6: Pushing to GitHub...
git push -u origin main

echo.
echo ========================================
echo Done! Check your repository at:
echo https://github.com/SrinathMLOps/AWSMultiAZ
echo ========================================
pause
