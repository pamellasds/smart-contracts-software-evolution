pragma solidity 0.5.17;

import ;
import ;


contract antcontroller is itokencontroller {
    string private constant error_not_minter = ;
    string private constant error_not_ant = ;

    iminimelike public ant;
    address public minter;

    event changedminter(address indexed minter);

    
    modifier onlyminter {
        require(msg.sender == minter, error_not_minter);
        _;
    }

    constructor(iminimelike _ant, address _minter) public {
        ant = _ant;
        _changeminter(_minter);
    }

    
    function generatetokens(address _owner, uint256 _amount) external onlyminter returns (bool) {
        return ant.generatetokens(_owner, _amount);
    }

    
    function changeminter(address _newminter) external onlyminter {
        _changeminter(_newminter);
    }

    
    
    
    

    
    function proxypayment(address ) external payable returns (bool) {
        
        require(msg.sender == address(ant), error_not_ant);
        return false;
    }

    
    function ontransfer(address , address , uint ) external returns (bool) {
        return true;
    }

    
    function onapprove(address , address , uint ) external returns (bool) {
        return true;
    }

    

    function _changeminter(address _newminter) internal {
        minter = _newminter;
        emit changedminter(_newminter);
    }
}
