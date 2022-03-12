pragma solidity >=0.4.24;


interface iethercollateralsusd {
    
    function totalissuedsynths() external view returns (uint256);

    function totalloanscreated() external view returns (uint256);

    function totalopenloancount() external view returns (uint256);

    
    function openloan(uint256 _loanamount) external payable returns (uint256 loanid);

    function closeloan(uint256 loanid) external;

    function liquidateunclosedloan(address _loancreatorsaddress, uint256 _loanid) external;

    function depositcollateral(address account, uint256 loanid) external payable;

    function withdrawcollateral(uint256 loanid, uint256 withdrawamount) external;

    function repayloan(
        address _loancreatorsaddress,
        uint256 _loanid,
        uint256 _repayamount
    ) external;
}
