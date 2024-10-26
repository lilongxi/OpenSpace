/*
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-23 20:01:21
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-24 09:12:36
 * @FilePath: /OpenSpace/src/chapter-010/person_sign.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import { Hex, keccak256, stringToHex } from "viem";

export function eip191Encode(message: string): Hex {
    const suffix = `\x19Ethereum Signed Message:\n:${message.length}`;
    const suffixMsg = suffix + message;
    return keccak256(stringToHex(suffixMsg));
}