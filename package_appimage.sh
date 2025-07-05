#!/bin/bash

# =========================================================================
# --- 项目配置 ---
# =========================================================================
APP_NAME="ShirohaPlayer"
EXEC_NAME="ShirohaPlayer"
BUILD_DIR="build"
APP_CATEGORIES="AudioVideo;Audio;Player;"
ICON_PATH="images/cloud.png"
ICON_NAME="cloud"

# !!! 修复：将缺失的 Qt5Compat.GraphicalEffects 添加到列表中 !!!
QML_MODULES_TO_DEPLOY=(
    "QtCore"
    "QtQuick"
    "QtQuick.Window"
    "QtQuick.Controls"
    "QtQuick.Layouts"
    "QtMultimedia"
    "Qt5Compat.GraphicalEffects"
)

# =========================================================================
# --- 工具配置 ---
# =========================================================================
LINUXDEPLOY_PATH="./linuxdeploy-x86_64.AppImage"
LINUXDEPLOY_URL="https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
QT_PLUGIN_PATH="./linuxdeploy-plugin-qt-x86_64.AppImage"
QT_PLUGIN_URL="https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage"

# =========================================================================
# --- 脚本主逻辑 (此部分无需再修改) ---
# =========================================================================
set -e
download_tool() {
  local path="$1" url="$2"
  if [ ! -f "$path" ]; then
    echo "正在下载 $(basename "$path")..."
    wget -q -c -O "$path" "$url"; chmod a+x "$path"
  fi
}
echo "--- 开始打包 AppImage ---"

# 0. 检查 qmake6
if ! command -v qmake6 &> /dev/null && ! command -v qmake-qt6 &> /dev/null; then
    echo "错误: 找不到 'qmake6' 或 'qmake-qt6'。请确保安装了 qt6-base 和 qt6-declarative。"; exit 1
fi
QMAKE_CMD=$(command -v qmake6 || command -v qmake-qt6)

# 1. 下载工具
download_tool "$LINUXDEPLOY_PATH" "$LINUXDEPLOY_URL"
download_tool "$QT_PLUGIN_PATH" "$QT_PLUGIN_URL"

# 2. 构建项目
echo "--- 正在构建项目 ---"
mkdir -p "$BUILD_DIR"
(cd "$BUILD_DIR" && cmake -DCMAKE_PREFIX_PATH=$($QMAKE_CMD -query QT_INSTALL_PREFIX) .. && make -j$(nproc))
APP_EXECUTABLE_PATH="$BUILD_DIR/$EXEC_NAME"
if [ ! -f "$APP_EXECUTABLE_PATH" ]; then echo "错误: 找不到可执行文件。"; exit 1; fi

# 3. 创建 AppDir
APPDIR_NAME="${APP_NAME}.AppDir"
rm -rf "$APPDIR_NAME"
mkdir -p "$APPDIR_NAME/usr/bin" "$APPDIR_NAME/usr/lib"
echo "创建 AppDir 于: $APPDIR_NAME"

# 4. 手动复制 QML 和插件
echo "--- 手动部署 QML 模块和插件 ---"
QML_TARGET_DIR="$APPDIR_NAME/usr/qml"
PLUGIN_TARGET_DIR="$APPDIR_NAME/usr/plugins"
mkdir -p "$QML_TARGET_DIR" "$PLUGIN_TARGET_DIR"
QML_SOURCE_DIR=$($QMAKE_CMD -query QT_INSTALL_QML)
PLUGIN_SOURCE_DIR=$($QMAKE_CMD -query QT_INSTALL_PLUGINS)
for module in "${QML_MODULES_TO_DEPLOY[@]}"; do
    module_path=$(echo "$module" | sed 's/\./\//g')
    echo "正在复制模块: $module (从 $QML_SOURCE_DIR/$module_path)"
    # 确保源目录存在
    if [ -d "$QML_SOURCE_DIR/$module_path" ]; then
        cp -r "$QML_SOURCE_DIR/$module_path" "$QML_TARGET_DIR/"
    else
        echo "警告: 找不到模块源目录 '$QML_SOURCE_DIR/$module_path'。请检查您的 Qt 安装。"
        echo "例如，在 Arch 上，确保安装了 'qt6-declarative' 和 'qt6-multimedia'。"
    fi
done
cp -r "$PLUGIN_SOURCE_DIR/multimedia" "$PLUGIN_TARGET_DIR/"
cp -r "$PLUGIN_SOURCE_DIR/platformthemes" "$PLUGIN_TARGET_DIR/"

# 5. 创建自定义的 AppRun 启动脚本
CUSTOM_APPRUN_PATH="${APPDIR_NAME}/AppRun"
echo "--- 正在创建自定义的 AppRun 启动脚本 ---"
cat > "$CUSTOM_APPRUN_PATH" <<\EOF
#!/bin/bash
APPDIR=$(dirname "$0")
export LD_LIBRARY_PATH="$APPDIR/usr/lib:$LD_LIBRARY_PATH"
export QT_PLUGIN_PATH="$APPDIR/usr/plugins"
export QML2_IMPORT_PATH="$APPDIR/usr/qml"
export QT_QPA_PLATFORM_PLUGIN_PATH="$APPDIR/usr/plugins/platforms"
exec "$APPDIR/usr/bin/ShirohaPlayer" "$@"
EOF
chmod +x "$CUSTOM_APPRUN_PATH"

# 6. 创建 .desktop 文件
DESKTOP_FILE_PATH="${APPDIR_NAME}/${APP_NAME}.desktop"
cat > "$DESKTOP_FILE_PATH" <<EOF
[Desktop Entry]
Name=$APP_NAME
Exec=AppRun
Icon=$ICON_NAME
Type=Application
Categories=$APP_CATEGORIES
EOF
if [ ! -f "$ICON_PATH" ]; then echo "错误: 找不到图标。"; exit 1; fi

# 7. 运行 linuxdeploy
echo "--- 正在运行 linuxdeploy ---"
export NO_STRIP=1
export QMAKE="$QMAKE_CMD"
"$LINUXDEPLOY_PATH" --appdir "$APPDIR_NAME" \
                    --executable "$APP_EXECUTABLE_PATH" \
                    --desktop-file "$DESKTOP_FILE_PATH" \
                    --icon-file "$ICON_PATH" \
                    --plugin qt \
                    --output appimage

# 8. 检查结果
FINAL_APPIMAGE=$(find . -maxdepth 1 -name "*.AppImage" ! -name "linuxdeploy*.AppImage" -print | head -n 1)
if [ -f "$FINAL_APPIMAGE" ]; then
    echo -e "\n--- 成功！ ---\nAppImage 已创建: $FINAL_APPIMAGE\n--------------------------"
else
    echo -e "\n--- 错误: AppImage 创建失败。---"; exit 1
fi

echo "--- 打包完成 ---"
