pragma solidity 0.4.25;


interface idelegateapprovals {
    function canburnfor(address owner, address delegate) external view returns (bool);

    function canissuefor(address owner, address delegate) external view returns (bool);

    function canclaimfor(address owner, address delegate) external view returns (bool);

    function canexchangefor(address owner, address delegate) external view returns (bool);
}
