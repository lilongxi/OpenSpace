/*
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-09 20:31:49
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-09 21:04:57
 * @FilePath: /OpenSpace/实践POW/index.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
const crypto = require('crypto');

function pow(data, difficulty) {
    console.time('pow');
    let nonce = 0;
    let hash;
    do {
        const input = data + nonce;
        hash = crypto.createHash('sha256').update(input).digest('hex');
        nonce++;
    } while (!hash.startsWith('0'.repeat(difficulty)));
    console.timeEnd('pow');
    return { nonce, hash };
}

function init(data = 'leelongxi') {
    const difficultyTo4 = pow(data, 4);
    console.log(difficultyTo4);
    const difficultyTo5 = pow(data, 5);
    console.log(difficultyTo5);
}

module.exports = {
    pow,
    init
}