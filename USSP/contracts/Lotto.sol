// SPDX-License-Identifier: MIT

// Cuurent contract address polygon: 0x7FAbEBaa16eB899fba6e04fF2d9F6310df5215Fb
pragma solidity ^0.8;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract Lotto is Initializable, AccessControlUpgradeable, PausableUpgradeable,   UUPSUpgradeable{

    // bytes32 internal _KEY = 0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da;
    address internal _safe ;
    // address internal _VRF = 0x3d2341ADb2D31f1c5530cDC622016af293177AE0;
    // address internal _LINK = 0xb0897686c545045aFc77CF20eC7A532E3120E0F1;

    address public winner;
    address[] public Pool;
    uint public PoolAmount;
    bool internal claimed;

    // uint internal _FEE = 0.0001 * 1e18;
    uint public winningNumber;
    uint startDay;
    uint lotteryPeriod;
    uint claimperiod;

    bool internal _win;

    AggregatorV3Interface internal priceFeed;
    IERC721 LottoTickets;

    bytes32 public constant CEO = keccak256("CEO");
    bytes32 public constant CTO = keccak256("CTO");
    bytes32 public constant CFO = keccak256("CFO");
    
    modifier validate() {
        require(
            hasRole(CEO, msg.sender) ||
                hasRole(CFO, msg.sender) ||
                hasRole(CTO, msg.sender),
            "AccessControl: Address does not have valid Rights"
        );
        _;
    }

    function initialize() initializer public {
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
         _safe = 0xd8806d66E24b702e0A56fb972b75D24CAd656821;
        address _L = 0xF814C9256Dc51AC1f6df4686786c40b534299f97;
        priceFeed = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada);
        LottoTickets = IERC721(_L);
        startDay = 1642420800;
        lotteryPeriod = startDay + 5 days;
        claimperiod = lotteryPeriod + 2 days;
        _win = false;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(CEO, msg.sender);
    }

    // function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    //     winningNumber = randomness;
    // }
    
    function getPrice() public view returns(uint){
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return uint(price);
    }

    function getDollar() public view returns(uint256){
        uint price = getPrice();
        return (uint(1e14) / price) * 1e12; // a dollar in matic
    }

    function getPot() public view returns(uint256){
        return PoolAmount;

    }

    function getPotUSD() public view returns(uint256){
        return (getPot()) * getPrice();
    }

    function getAnnounceDate() public view returns(uint256){
        return lotteryPeriod + 1 days;
    }

    function getPlayerCount() public view returns(uint256){
      
            return Pool.length;
    }


    function startLottery(uint _start, uint _duration) public validate {
        resetLottery();
        startDay = _start;
        lotteryPeriod = startDay + _duration * 1 days;
        claimperiod = lotteryPeriod + 2 days;
    }

    function resetLottery() public validate {
        // startLottery(claimperiod, 5);
        require(block.timestamp > claimperiod, "Cannot reset Lottery before prevoius Claim period end");
        Pool = [address(0)];
        PoolAmount = 0;
        winner = address(0);
    }

    function BuyTicket() public payable{
        require(block.timestamp < lotteryPeriod, "Lottery Period Ended: No More buying allowed");
        uint onedollar = getDollar();
        require(msg.value >= onedollar, "Buy Lottery Ticket: Price should be greater than 1 USD");
        Pool.push(msg.sender); // Pool1 is the 1 USD pool
        LottoTickets.safeMint(msg.sender, (Pool.length * 10));
        PoolAmount +=  msg.value - gasleft();
    }


    function AnnounceLotteryWinner() public validate{
        require(block.timestamp > lotteryPeriod, "Lottery Period Not Ended: No winners yet");
        require(_win == false, "Cannot Announce winner yet");
        // winningNumber = uint(blockhash(block.number - 1)) % Players.length;

        uint winningOne = uint(blockhash(block.number - 1)) % Pool.length;
        winner = Pool[winningOne];
        _win = true;
    }

    function claim() public {
        require(_win == true);
        require(block.timestamp > lotteryPeriod, "Lottery Period: Still buying tickets");
        require(block.timestamp < claimperiod, "Claim Period: Invalid Claim Period");
        // require(msg.sender == winner, "Error: You are not the winner");
        require((msg.sender == winner) , "Error: You are not the winner");
        
   
        if(winner == msg.sender) // 1 USD Pot

        uint poolpot = PoolAmount;
        require(claimed == false, "Claim: Prize already Claimed");

        uint cut = poolpot * 5 / 100;
        uint pot = poolpot - cut;

        payable(_safe).transfer(cut);
        payable(winner).transfer(pot);

        claimed = true;
        // _win = false;
    } 
        function _authorizeUpgrade(address newImplementation)
        internal
        validate
        override
    {}
}


interface IERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeMint(address to, uint256 tokenId) external;
    function safeBurn(address to, uint256 tokenId) external;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function safeTransfer(address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}