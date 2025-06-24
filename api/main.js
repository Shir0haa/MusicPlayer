const fs = require('fs');
const path = require('path');
const tmpPath = require('os').tmpdir();
const { cookieToJson } = require('./util');

// 获取当前工作目录 - 兼容 pkg 打包环境
function getModuleDir() {
  // 如果是打包环境，使用 process.cwd() 获取真实文件系统路径
  if (process.pkg) {
    return path.join(process.cwd(), 'module');
  }
  // 开发环境使用 __dirname
  return path.join(__dirname, 'module');
}

// 确保临时文件存在
if (!fs.existsSync(path.resolve(tmpPath, 'anonymous_token'))) {
  fs.writeFileSync(path.resolve(tmpPath, 'anonymous_token'), '', 'utf-8');
}

let firstRun = true;
/** @type {Record<string, any>} */
let obj = {};

const moduleDir = getModuleDir();
const files = fs.readdirSync(moduleDir).reverse();

files.forEach((file) => {
  if (!file.endsWith('.js')) return;

  const fn = file.split('.').shift() || '';
  const filePath = path.join(moduleDir, file);

  // 在 pkg 环境中使用动态 require
  // 在开发环境中使用静态 require
  let fileModule;
  if (process.pkg) {
    // 在打包环境中，使用动态 require 确保模块被正确包含
    fileModule = require(filePath);
  } else {
    // 在开发环境中使用原始方式
    fileModule = require(`./module/${file}`);
  }

  obj[fn] = function (data = {}) {
    if (typeof data.cookie === 'string') {
      data.cookie = cookieToJson(data.cookie);
    }

    return fileModule(
      {
        ...data,
        cookie: data.cookie ? data.cookie : {},
      },
      async (...args) => {
        if (firstRun) {
          firstRun = false;
          // 动态加载 generateConfig
          const generateConfig = process.pkg ?
          require(path.join(process.cwd(), 'generateConfig')) :
          require('./generateConfig');
          await generateConfig();
        }

        // 动态加载 request
        const request = process.pkg ?
        require(path.join(process.cwd(), 'util/request')) :
        require('./util/request');

        return request(...args);
      }
    );
  };
});

// 导出模块
module.exports = {
  ...(process.pkg ?
  require(path.join(process.cwd(), 'server')) :
  require('./server')),
  ...obj
};
