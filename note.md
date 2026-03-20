pkill -f flutter
flutter run -d chrome --web-port 8080
flutter build web --web-renderer html --release
cd build/web                                
python3 -m http.server 8080 --bind 0.0.0.0


cd /Users/imac/Documents/projects/self/suWater-mobile-app
flutter build web --web-renderer html --release
cd build/web
python3 -m http.server 8080 --bind 0.0.0.0


lsof -ti:8080 | xargs kill -9
