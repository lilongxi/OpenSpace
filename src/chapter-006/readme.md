<!--
 * @Author: leelongxi leelongxi@foxmail.com
 * @Date: 2024-10-16 09:36:16
 * @LastEditors: leelongxi leelongxi@foxmail.com
 * @LastEditTime: 2024-10-17 09:39:20
 * @FilePath: /OpenSpace/src/chapter-006/readme.md
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
-->
# ERC20
1. 转帐无法携带额外信息
2. 没有转帐回调（依赖授权、误入合约锁死）
3. 合约只有转账回调 无法感知成功回调
4. 什么是锁死：比如一个合约依赖一定数量的 token 执行后续逻辑 但是转入转出失败 就会导致后续流程中断

# ERC777
1. send(dest, value, data)
2. 防止误入合约被锁死
3. 普通地址实现回调
4. 全局注册合约表（ERC1820）注册回调监听

# ERC1363


# 作业链接
1. https://decert.me/challenge/65e9c4a1-a2ee-41ea-b8d7-7a5a1a945cbc
2. https://decert.me/challenge/852f5836-a03d-4483-a7e0-b0f6f8bda01c
3. https://decert.me/challenge/abdbc346-8314-4394-8f97-8732780602ed
4. https://decert.me/quests/4df553df-fbab-49c8-a05f-83256432c6af