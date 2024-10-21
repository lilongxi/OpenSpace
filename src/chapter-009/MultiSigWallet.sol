// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "oz_v5/contracts/access/Ownable.sol";
import "oz_v5/contracts/utils/Context.sol";

contract MultiSigWallet is Ownable {

    constructor(address[] memory _owners, uint _threshold) Ownable(_msgSender()) {
        threshold = _threshold;
        _initalizaSigWallet(_owners, _threshold);
    }

    struct Transcation {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint confirmCount;
    }

    address[] public owners;
    uint public threshold; // 签名门槛 最小签名数量
    mapping (address => bool) public isOwner; 
    mapping (uint => mapping(address => bool)) public isConfirmed; // 记录已经签过的人

    Transcation[] public transactions; // 存储提按

    event TransactionSubmitted(uint indexed txIndex, address indexed to, uint value, bytes data);
    event TransactionConfirmed(uint indexed txIndex, address indexed owner);
    event TransactionExecuted(uint indexed txIndex);

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "Transaction already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][_msgSender()], "Transaction already confirmed");
        _;
    }

    function _initalizaSigWallet(address[] memory _owners, uint _threshold) private {
        require(_owners.length > 0, "Owners required");
        require(_threshold > 0 && _threshold <= _owners.length, "Invalid threshold");

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }

    }

    // 提交提案 发起一笔多签交易
    function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner {
        transactions.push(Transcation({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            confirmCount: 0
        }));
        emit TransactionSubmitted(transactions.length - 1, _to, _value, _data);
    }

    // 确认提案 从第 txIndex 确认提案
    function confirmTransaction(uint _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex) {

        address owner = _msgSender();
        Transcation storage transaction = transactions[_txIndex];
        transaction.confirmCount += 1;
        isConfirmed[_txIndex][owner] = true;

        emit TransactionConfirmed(_txIndex, owner);
    }

    // 执行提案 safWallet 的 Execute 方法
    function executeTransaction (uint _txIndex) public txExists(_txIndex) notExecuted(_txIndex) {
        Transcation storage transaction = transactions[_txIndex];
        require(transaction.confirmCount >= threshold, "Cannot execute, confirmations below threshold");

        transaction.executed = true;

        (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "Transaction failed");

        emit TransactionExecuted(_txIndex);

    }

    receive() external payable {}


}