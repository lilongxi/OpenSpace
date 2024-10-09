const crypto = require('crypto');
const { pow } = require('../实践POW/index');
const { generateKeys, passphrase } = require('./rsa');

function sign(data, privateKey) {
    const sign = crypto.createSign('SHA256');
    sign.update(data);
    sign.end();
    const signature = sign.sign({
        key: privateKey,
        padding: crypto.constants.RSA_PKCS1_PSS_PADDING,
        passphrase
    }, 'base64')
    return signature
}

function verify(data, signature, publicKey) {
    const verify = crypto.createVerify('SHA256');
    verify.update(data);
    verify.end();
    const result = verify.verify({
        key: publicKey,
        padding: crypto.constants.RSA_PKCS1_PSS_PADDING,
        passphrase
    }, signature, 'base64');
    return result
}

function rsa(data) {
    const { nonce } = pow(data, 4);
    console.time('rsa')
    const { publicKey, privateKey } = generateKeys();
    const message = data + nonce;
    const signature = sign(message, privateKey);
    const result = verify(message, signature, publicKey);
    console.timeEnd('rsa')
    return result;
}

console.log(rsa('leelongxi'));