
pragma solidity 0.6.12;
import ;


interface iconversionpathfinder {
    function findpath(ierc20token _sourcetoken, ierc20token _targettoken) external view returns (address[] memory);
}
