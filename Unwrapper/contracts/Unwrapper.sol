// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface IERC20 {
    function burn(address from, uint256 amount) external;
    function mint(address to, uint256 amount) external;
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Unwrapper is AccessControl{
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    IERC20 USDT;
    IERC20 wUSDT;

    bool private _swapOpen = false;

    constructor(address _USDT, address _wUSDT) public {
        USDT = IERC20(_USDT);
        wUSDT = IERC20(_wUSDT);
        _grantRole(OWNER_ROLE, msg.sender);
    }

    function setTokens(address _USDT, address _wUSDT) public onlyRole(OWNER_ROLE) {
        USDT = IERC20(_USDT);
        wUSDT = IERC20(_wUSDT);
    }

    function swapOpen() public view returns (bool) {
        return _swapOpen;
    }

    function setSwapOpen(bool _val) public onlyRole(OWNER_ROLE){
        _swapOpen = _val;
    }

    function unwrap(uint256 amount) public {
        require(_swapOpen);
        require(wUSDT.balanceOf(msg.sender) >= amount);
        wUSDT.burn(msg.sender, amount);
        USDT.mint(msg.sender, amount);
    }

    function wrap(uint256 amount) public {
        require(_swapOpen);
        require(USDT.balanceOf(msg.sender) >= amount);
        USDT.burn(msg.sender, amount);
        wUSDT.mint(msg.sender, amount);
    }
}