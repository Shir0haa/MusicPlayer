const fs = require('fs')
const path = require('path')
const { cookieToJson, generateRandomChineseIP } = require('./util/index')
const tmpPath = require('os').tmpdir()

async function generateConfig() {
  global.cnIp = generateRandomChineseIP()
  try {
    // 动态加载 main.js 模块
    const mainModule = process.pkg ?
    require(path.join(process.cwd(), 'main')) :
    require('./main')

    // 调用匿名注册功能
    const res = await mainModule.register_anonimous()
    const cookie = res.body.cookie

    if (cookie) {
      const cookieObj = cookieToJson(cookie)
      fs.writeFileSync(
        path.resolve(tmpPath, 'anonymous_token'),
                       cookieObj.MUSIC_A,
                       'utf-8',
      )
    }
  } catch (error) {
    console.log('generateConfig error:', error)
  }
}
module.exports = generateConfig
