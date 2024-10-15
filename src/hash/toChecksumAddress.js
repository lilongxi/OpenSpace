/*
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-15 09:35:19
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-15 09:35:35
 * @FilePath: /OpenSpace/src/hash/toChecksumAddress.js
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
const createKeccakHash = require('keccak')

function toChecksumAddress (address) {
  address = address.toLowerCase().replace('0x', '')
  var hash = createKeccakHash('keccak256').update(address).digest('hex')
  var ret = '0x'

  for (var i = 0; i < address.length; i++) {
    if (parseInt(hash[i], 16) >= 8) {
      ret += address[i].toUpperCase()
    } else {
      ret += address[i]
    }
  }

  return ret
}