@echo off
for /r %%f in (*.png) do (
    magick "%%f" -resize 50%% "%%f"
)
echo Done!
pause