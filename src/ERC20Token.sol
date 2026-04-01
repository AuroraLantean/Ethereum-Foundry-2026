// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;
//=> ERC-3643, ERC-1400, ERC-1155

//import "solmate/tokens/ERC20.sol";
//import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; //_mint, _burn

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; //safeTransfer, safeTransferFrom, safeApprove, safeIncreaseAllowance, safeDecreaseAllowance
import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";
import "@openzeppelin/contracts/interfaces/IERC1363Spender.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC1363.sol";
import "forge-std/console.sol";

contract ERC20Token is Ownable, ERC20, ERC20Burnable {
    constructor(string memory name, string memory symbol) Ownable(msg.sender) ERC20(name, symbol) {
        _mint(msg.sender, 9000000000 * 10 ** uint256(decimals()));
    }

    function mintToGuest() public {
        _mint(msg.sender, 100 * 10 ** uint256(decimals()));
    }

    function mint(address user, uint256 amount) public onlyOwner returns (bool) {
        _mint(user, amount);
        return true;
    }

    function getData(address target) public view returns (string memory, uint8, uint256) {
        return (symbol(), decimals(), balanceOf(target));
    }
}

//USDT, USDC use 6 dp !!! But DAI uses 18!!
contract USDX is ERC20Token {
    constructor(string memory name, string memory symbol) ERC20Token(name, symbol) {}

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}

interface IERC20Receiver {
    function tokenReceived(address from, uint256 amount, bytes calldata data) external returns (bytes4);
}

contract ERC20Receiver is IERC20Receiver {
    using SafeERC20 for IERC20;

    event TokenReceived(address indexed from, uint256 indexed amount, bytes data);

    bytes4 private constant _ERC20_RECEIVED = 0x8943ec02;
    // Equals to `bytes4(keccak256(abi.encodePacked("tokenReceived(address,uint256,bytes)")))`
    // OR IERC20Receiver.tokenReceived.selector

    function tokenReceived(address from, uint256 amount, bytes calldata data) external returns (bytes4) {
        //console.log("tokenReceived");
        emit TokenReceived(from, amount, data);
        return _ERC20_RECEIVED;
    }

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    //to withdraw
    /*function transfer(address erc20Addr, address to, uint256 amount) public {
        IERC20(erc20Addr).transfer(to, amount);
    }*/

    // If `token` returns no value, non-reverting calls are assumed to be successful.
    function withdraw(address erc20Addr, address to, uint256 amount) public {
        require(msg.sender == owner, "not owner");
        IERC20(erc20Addr).safeTransfer(to, amount);
    }

    //to deposit: from = address(this)
    //to transfer: from = another contract
    /*function transferFrom(address erc20Addr, address from, uint256 amount) public {
        IERC20(erc20Addr).transferFrom(msg.sender, from, amount);
    }*/

    //calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
    function deposit(address erc20Addr, uint256 amount) public {
        IERC20(erc20Addr).safeTransferFrom(msg.sender, address(this), amount);
    }

    //returns a bool instead of reverting if the operation is not successful.
    function tryWithdraw(address erc20Addr, address to, uint256 amount) public {
        require(msg.sender == owner, "not owner");
        IERC20(erc20Addr).trySafeTransfer(to, amount);
    }

    //returns a bool instead of reverting if the operation is not successful.
    function tryDeposit(address erc20Addr, uint256 amount) public {
        IERC20(erc20Addr).trySafeTransferFrom(msg.sender, address(this), amount);
    }

    /*If `token` returns no value, non-reverting calls are assumed to be successful.

    IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client" smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
    this function.

    Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior. */
    function safeIncreaseAllowance(address erc20Addr, address spender, uint256 amount) public {
        IERC20(erc20Addr).safeIncreaseAllowance(spender, amount);
    }

    /* If `token` returns no value, non-reverting calls are assumed to be successful.

    IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client" smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using this function.

    Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior. */
    function safeDecreaseAllowance(address erc20Addr, address spender, uint256 amount) public {
        IERC20(erc20Addr).safeDecreaseAllowance(spender, amount);
    }

    /* If `token` returns no value,non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval to be set to zero before setting it to a non-zero value, such as USDT.

    NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being set here. */
    function forceApprove(address erc20Addr, address spender, uint256 amount) public {
        IERC20(erc20Addr).forceApprove(spender, amount);
    }

    function safePermit(
        address erc20Addr,
        IERC20Permit token,
        address tokenOwner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        //IERC20(erc20Addr).safePermit(token, tokenOwner, spender, value, deadline, v, r, s);
    }

    function executeTxn(address _ctrt, uint256 _value, bytes calldata _data) public {
        //console.log("executeTxn()...", _data, msg.value);
        (
            bool success, /*bytes memory _databk*/
        ) = _ctrt.call{value: _value}(_data);
        //console.logBytes(_databk);
        require(success, "tx failed");
    }

    //be careful of function signature typo, and arg types
    function makeCalldata(string memory _funcSig, address to, uint256 amount) public pure returns (bytes memory) {
        //_funcSig example: "transfer(address,uint256)"
        return abi.encodeWithSignature(_funcSig, to, amount);
    }

    function makeBytes() public pure returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked("tokenReceived(address,uint256,bytes)")));
    }

    function makeBytes2() public pure returns (bytes4) {
        return IERC20Receiver.tokenReceived.selector;
    }

    receive() external payable {
        revert("should not send any ether directly");
    }
}

//----------------== ERC1363
/*Problem/Danger of using ERC20 transferFrom()
- The user has to approve the contract to transfer the tokens, and it costs gas.
- the user should to set the approval for the contract to zero after approving the contract, otherwise if the contract is exploited, it can withdraw additional ERC-20 tokens from the user.

ERC-1363 extends the ERC-20 standard, adding transfer hooks so that... the token contract, after calling the transfer(), calls the predefined function(onTransferReceived) on the recipient address.*/

//--------== ERC1363 Token
contract ERC1363Token is Ownable, ERC1363, ERC20Burnable {
    constructor(string memory name, string memory symbol) Ownable(msg.sender) ERC20(name, symbol) {
        _mint(msg.sender, 9000000000 * 10 ** uint256(decimals()));
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function mintToGuest() public {
        _mint(msg.sender, 100 * 10 ** uint256(decimals()));
    }

    function mint(address user, uint256 amount) public onlyOwner returns (bool) {
        _mint(user, amount);
        return true;
    }

    function getData(address target) public view returns (string memory, uint8, uint256) {
        return (symbol(), decimals(), balanceOf(target));
    }

    /*
    transfer(to, value)
    IERC1363Receiver(to).onTransferReceived(operator=_msgSender(), from=_msgSender(), value, data)    */
    function transferAndCall(address to, uint256 value, bytes memory data) public override returns (bool) {
        return super.transferAndCall(to, value, data);
    }

    /* transferFrom(from, to, value)
    IERC1363Receiver(to).onTransferReceived(operator=_msgSender(), from, value, data) */
    function transferFromAndCall(address from, address to, uint256 value, bytes memory data)
        public
        override
        returns (bool)
    {
        return super.transferFromAndCall(from, to, value, data);
    }

    /*replicate USDT approval behavior
    approve(spender, value)
    IERC1363Spender(spender).onApprovalReceived(operator=_msgSender(), value, data) to send tokens: transferFrom(owner, target, value)   */
    function approveAndCall(address spender, uint256 value, bytes memory data) public override returns (bool) {
        require(value == 0 || allowance(msg.sender, spender) == 0, "existing allowance detected");
        return super.approveAndCall(spender, value, data);
    }
}

//contracts/interfaces/IERC1363Receiver.sol
contract ERC1363Receiver is IERC1363Receiver {
    using SafeERC20 for IERC1363;

    address immutable erc1363Token;

    constructor(address erc1363Token_) {
        erc1363Token = erc1363Token_;
    }

    mapping(address user => uint256 balance) public balances;

    event Deposit(address indexed from, address indexed beneficiary, uint256 value);

    //bytes4 private constant _ERC1363_RECEIVED = 0x88a7ca5c;
    /* Whenever ERC-1363 tokens are transferred to this contract via `transferAndCall` or `transferFromAndCall`
     * by `operator` from `from`, this function is called.
     *
     * NOTE: To accept the transfer, this must return `bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))`
     * (i.e. 0x88a7ca5c, or its own function selector).
     *
     * @param operator The address which called `transferAndCall` or `transferFromAndCall` function.
     * @param data Additional data with no specified format.
     * @return `bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"))` if transfer is allowed unless throwing.  */
    function onTransferReceived(address operator, address from, uint256 value, bytes calldata data)
        external
        returns (bytes4)
    {
        //always check that msg.sender is the ERC-1363 !!!
        require(msg.sender == erc1363Token, "caller should be the ERC1363 token");

        address beneficiary;
        if (data.length == 32) {
            beneficiary = abi.decode(data, (address));
        } else {
            beneficiary = from;
        }
        balances[from] += value;
        emit Deposit(from, beneficiary, value);

        return IERC1363Receiver.onTransferReceived.selector;
        //this.onTransferReceived.selector;
    }

    function withdraw(uint256 value) external {
        require(balances[msg.sender] >= value, "balance too low");
        balances[msg.sender] -= value;

        IERC1363(erc1363Token).transfer(msg.sender, value);
    }

    /* Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when targeting contracts.
    Reverts if the returned value is other than `true`.  */
    function transferAndCallRelaxed(address erc1363Addr, address to, uint256 amount, bytes memory data) public {
        IERC1363(erc1363Addr).transferAndCallRelaxed(to, amount, data);
    }

    /* Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when targeting contracts.
    Reverts if the returned value is other than `true`.*/
    function transferFromAndCallRelaxed(
        address erc1363Addr,
        address from,
        address to,
        uint256 amount,
        bytes memory data
    ) public {
        IERC1363(erc1363Addr).transferFromAndCallRelaxed(from, to, amount, data);
    }

    /* Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when targeting contracts.

    NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
    Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
    once without retrying, and relies on the returned value to be true.
    Reverts if the returned value is other than `true`. */
    function approveAndCallRelaxed(address erc1363Addr, address to, uint256 amount, bytes memory data) public {
        IERC1363(erc1363Addr).approveAndCallRelaxed(to, amount, data);
    }
}

contract ERC1363Spender is IERC1363Spender {
    address immutable erc1363Token;
    mapping(address => bool) isApprovedToken;

    constructor(address _erc1363Token) {
        erc1363Token = _erc1363Token;
    }

    function onApprovalReceived(address owner, uint256 value, bytes calldata data) external override returns (bytes4) {
        require(msg.sender == erc1363Token, "caller should be the ERC1363 token");
        require(isApprovedToken[msg.sender], "not an approved token");

        address target;
        if (data.length == 32) {
            target = abi.decode(data, (address));
        } else {
            revert("no target");
        }
        bool success = IERC1363(msg.sender).transferFrom(owner, target, value);
        require(success, "transfer failed");

        IERC1363(msg.sender).approve(address(this), 0);

        return IERC1363Spender.onApprovalReceived.selector;
        //this.onApprovalReceived.selector;
    }
}
