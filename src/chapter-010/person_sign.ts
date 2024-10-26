/*
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-23 20:01:21
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-26 11:37:07
 * @FilePath: /OpenSpace/src/chapter-010/person_sign.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import { Hex, keccak256, stringToHex, isAddressEqual, recoverMessageAddress } from "viem";
import { privateKeyToAccount } from "viem/accounts";

export function eip191Encode(message: string): Hex {
    const suffix = `\x19Ethereum Signed Message:\n:${message.length}`;
    const suffixMsg = suffix + message;
    return keccak256(stringToHex(suffixMsg));
}

const account = privateKeyToAccount("0x355eb1c3D6dF0642b3abe2785e821C574837C79f")
console.log(account.address)

const signature = account.signMessage({ message: 'Hello Wrold!' }).then((sign) => {
    recoverMessageAddress({ message: 'Hello Wrold!', signature: sign }).then((recoveredAddress) => {
        console.log(isAddressEqual(recoveredAddress, '0x355eb1c3D6dF0642b3abe2785e821C574837C79f'))
    })
})

