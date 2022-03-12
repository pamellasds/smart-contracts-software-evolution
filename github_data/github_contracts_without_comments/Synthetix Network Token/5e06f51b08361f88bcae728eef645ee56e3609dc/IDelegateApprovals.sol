pragma solidity ^0.5.16;


interface idelegateapprovals {
    
    function canburnfor(address authoriser, address delegate) external view returns (bool);

    function canissuefor(address authoriser, address delegate) external view returns (bool);

    function canclaimfor(address authoriser, address delegate) external view returns (bool);

    function canexchangefor(address authoriser, address delegate) external view returns (bool);

    
    function approvealldelegatepowers(address delegate) external;

    function removealldelegatepowers(address delegate) external;

    function approveburnonbehalf(address delegate) external;

    function removeburnonbehalf(address delegate) external;

    function approveissueonbehalf(address delegate) external;

    function removeissueonbehalf(address delegate) external;

    function approveclaimonbehalf(address delegate) external;

    function removeclaimonbehalf(address delegate) external;

    function approveexchangeonbehalf(address delegate) external;

    function removeexchangeonbehalf(address delegate) external;
}
