pragma solidity >=0.4.24;


interface iethercollateral {
    
    function totalissuedsynths() external view returns (uint256);

    function totalloanscreated() external view returns (uint256);

    function totalopenloancount() external view returns (uint256);

    
    function openloan() external payable returns (uint256 loanid);

    function closeloan(uint256 loanid) external;

    function liquidateunclosedloan(address _loancreatorsaddress, uint256 _loanid) external;
}
