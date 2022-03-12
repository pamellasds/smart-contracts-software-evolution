pragma solidity ^0.5.16;

import ;

import ;

import ;


contract faketradingrewards is tradingrewards {
    ierc20 public _mocksynthetixtoken;

    constructor(
        address owner,
        address periodcontroller,
        address resolver,
        address mocksynthetixtoken
    )
        public
        tradingrewards(owner, periodcontroller, resolver)
    {
        _mocksynthetixtoken = ierc20(mocksynthetixtoken);
    }

    
    function synthetix() internal view returns (ierc20) {
        return ierc20(_mocksynthetixtoken);
    }

    
    function exchanger() internal view returns (iexchanger) {
        return iexchanger(msg.sender);
    }

    
    function ethbackdoor() external payable {}
}
