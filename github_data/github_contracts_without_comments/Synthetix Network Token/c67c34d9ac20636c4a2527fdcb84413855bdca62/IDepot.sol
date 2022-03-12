pragma solidity 0.4.25;



contract idepot {
    function exchangeetherforsynths() public payable returns (uint);

    function exchangeetherforsynthsatrate(uint guaranteedrate) external payable returns (uint);

    function depositsynths(uint amount) external;

    function withdrawmydepositedsynths() external;

    
    function exchangeetherforsnx() external payable returns (uint);

    function exchangeetherforsnxatrate(uint guaranteedrate) external payable returns (uint);

    function exchangesynthsforsnx() external payable returns (uint);
}
