# 🖥️ Настройка VNC Server на SteamDeck (Plasma X11)

Этот гайд подробно описывает, как настроить **VNC сервер на SteamDeck** с использованием **TigerVNC**, чтобы можно было удалённо подключаться к графической среде Plasma X11.  
Скрипт автоматически ждёт запуска графической среды, выбирает свободный дисплей, запускает VNC и проверяет открытие порта.

---

## 📦 Шаг 1. Установка TigerVNC

```bash
sudo steamos-readonly disable
sudo pacman -Scc
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman-key --populate holo
sudo pacman-key --refresh-keys
sudo pacman -Syu
sudo pacman -Syu git
sudo pacman -S tigervnc
sudo steamos-readonly enable
vncserver -version
```

---

## Шаг 1.1. Настройка пароля VNC

```bash
vncpasswd
```

Файл пароля: `~/.vnc/passwd`.

---

## ⚙️ Шаг 2. Создание скрипта запуска VNC

## Файлы в этом репо

- `scripts/start-vnc.sh` — запуск VNC с ретраями и логом.
    
- `systemd/vncserver.service` — unit для автозапуска (user service).

---

## Шаг 2.1. Развёртывание на SteamDeck скрипта запуска VNC и systemd-сервиса для автозапуска

```bash
# скопируйте файлы
install -Dm755 scripts/start-vnc.sh ~/.vnc/start-vnc.sh
install -Dm644 systemd/vncserver.service ~/.config/systemd/user/vncserver.service

# перезапустите user systemd
systemctl --user daemon-reload
systemctl --user enable vncserver.service
systemctl --user start vncserver.service
systemctl --user status vncserver.service
```

---

## Шаг 3. Проверка и просмотр логов

```bash
cat ~/vnc-start.log
ss -tlnp | grep 59
```

---

## Шаг 4. Подключение

Подключайтесь клиентом (TigerVNC/RealVNC) к `IP:5902`.

---

## ⚡ Особенности работы

- Скрипт ждёт запуска графической среды SteamDeck (game mode).
    
- Автоматически выбирается свободный дисплей (2–5).
    
- После запуска проверяется, что порт открыт.
    
- В случае ошибки выполняются повторные попытки (максимум 3).
    
- Ведется запись логов, с датой и временем.
    
---

## 💡 Рекомендации

- Проверяйте логи `/home/deck/vnc-start.log` при проблемах.
    
- Для подключения используйте любой VNC-клиент на Windows/Linux/Mac.
    
- При обновлениях SteamDeck убедитесь, что TigerVNC установлен и работает.

---

## 🛠 Issues / Contribution

Если нашли баг 🐛 или хотите предложить улучшение 🚀 — создайте [Issue](https://github.com/sayanss2/steamdeck-tigervnc-setup/issues) или [Pull Request](https://github.com/sayanss2/steamdeck-tigervnc-setup/pulls).

Будет здорово, если при создании Issue вы укажете:
- **ОС и версию SteamOS**
- **Логи из `~/.vnc/vnc-start.log`**
- **Пошаговое описание** как воспроизвести проблему

---

💡 Хочешь помочь проекту?
- Форкните репозиторий
- Создайте новую ветку: `git checkout -b feature/my-improvement`
- Внесите изменения и сделайте коммит
- Отправьте Pull Request 🎉

---

## 📜 License

Этот проект распространяется под лицензией MIT License.  
См. [LICENSE](./LICENSE) для деталей.
