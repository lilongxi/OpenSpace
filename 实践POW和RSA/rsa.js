/*
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-09 21:05:58
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-09 21:29:04
 * @FilePath: /OpenSpace/实践POW和RSA/rsa.js
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
const crypto = require('crypto');

const passphrase = 'secret by OpenSpace';
const options = {
    modulusLength: 2048,
    publicKeyEncoding: {
        type: 'spki',
        format: 'pem'
    },
    privateKeyEncoding: {
        type: 'pkcs8',
        format: 'pem',
        cipher: 'aes-256-cbc',
        passphrase
    }
};

function generateKeys() {
    const { publicKey, privateKey } = crypto.generateKeyPairSync('rsa', options);
    return { publicKey, privateKey };
}

module.exports = {
    generateKeys,
    passphrase
}