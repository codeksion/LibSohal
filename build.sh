mkdir libsohal

sudo echo "root permision granted!"

if [[ ! -n "$(command -v go)" ]]; then # Ensure go is installed
   echo "Go not found."
   echo "Use:"
   echo ""
   echo "wget https://go.dev/dl/go1.18.2.linux-amd64.tar.gz -O /tmp/go1.18.2.tar.gz"
   echo "tar -C /usr/local/ -xzf /tmp/go1.18.2.tar.gz" 
   echo "echo -e '\nPATH="\$PATH:/usr/local/go/bin"' >> $HOME/.bashrc"
   echo "rm /tmp/go1.18.2.tar.gz"
   exit
fi
echo "Compiling backend"
cd backend
go mod tidy -v || exit 
go build -x -v . || exit 
go build -x -v ./cmd/utils || exit
cp backend utils ../libsohal
python3 -c "import easyocr" || echo -e "python3 ya da easyocr kurulu değil\n$:\tpython3 -m pip install easyocr"
chmod +x easyocrbin
sudo cp easyocrbin /usr/bin/

cd ..

echo "Service file creating"
echo "!NOTE: Add 'After=mongo.target' line after [UNIT] tag to start service after mongo service"

echo -n """
[Unit]
Description=LibSohal Backend software
StartLimitIntervalSec=10

[Service]
Type=simple
Restart=always
RestartSec=5
WorkingDirectory=$PWD/libsohal
ExecStart=$PWD/libsohal

[Install]
WantedBy=multi-user.target
""" > libsohal-backend.service


echo "Service file created: libsohal-backend.service"
echo "!NOTE: Add 'After=mongo.target' line after [UNIT] tag to start service after mongo service"

echo "Compiling Client-(Android)-Side"

cd frontend
flutter pub get || exit
flutter build apk --release -v  || exit
cd ..

cp frontend/build/app/outputs/flutter-apk/app-release.apk libsohal/libsohal-frontend.apk

echo "Done!"
echo "Your compiled binaries in ./libsohal:"
ls libsohal

echo "Touching server-side .env file. EDIT libsohal/.env FILE!"

echo -e "MONGO_ADDR=\nFIBER_ADDR=0.0.0.0:80" > libsohal/.env

echo "Notes:"
echo -e "\tYou can use: ./libsohal/utils --ip command to find server local ip"
echo -e "\tYou can activate systemd service with: sudo cp libsohal-backend.service /etc/systemd/system/ ; sudo systemctl enable --now libsohal-backend.service"

