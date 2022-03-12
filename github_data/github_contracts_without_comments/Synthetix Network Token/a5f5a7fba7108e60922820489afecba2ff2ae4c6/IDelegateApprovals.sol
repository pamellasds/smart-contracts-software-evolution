pragma solidity 0.4.25;


interface idelegateapprovals {
    function canburnfor(address authoriser, address delegate) external view returns (bool);

    function canissuefor(address authoriser, address delegate) external view returns (bool);

    function canclaimfor(address authoriser, address delegate) external view returns (bool);

    function canexchangefor(address authoriser, address delegate) external view returns (bool);
}
