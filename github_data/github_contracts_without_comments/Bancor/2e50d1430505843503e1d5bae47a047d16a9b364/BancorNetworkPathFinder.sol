pragma solidity 0.4.26;
import ;
import ;
import ;
import ;
import ;
import ;


contract bancornetworkpathfinder is contractids, utils {
    icontractregistry public contractregistry;
    address public anchortoken;

    bytes4 private constant connector_token_count = bytes4(uint256(keccak256() >> (256  4 * 8)));
    bytes4 private constant reserve_token_count   = bytes4(uint256(keccak256(  ) >> (256  4 * 8)));

    
    constructor(icontractregistry _contractregistry) public validaddress(_contractregistry) {
        contractregistry = _contractregistry;
        anchortoken = contractregistry.addressof(bnt_token);
    }

    
    function updateanchortoken() external {
        address bnttoken = contractregistry.addressof(bnt_token);
        require(anchortoken != bnttoken);
        anchortoken = bnttoken;
    }

    
    function get(address _sourcetoken, address _targettoken, ibancorconverterregistry[] memory _converterregistries) public view returns (address[] memory) {
        assert(anchortoken == contractregistry.addressof(bnt_token));
        address[] memory sourcepath = getpath(_sourcetoken, _converterregistries);
        address[] memory targetpath = getpath(_targettoken, _converterregistries);
        return getshortestpath(sourcepath, targetpath);
    }

    
    function getpath(address _token, ibancorconverterregistry[] memory _converterregistries) private view returns (address[] memory) {
        if (_token == anchortoken) {
            address[] memory initialpath = new address[](1);
            initialpath[0] = _token;
            return initialpath;
        }

        uint256 tokencount;
        uint256 i;
        address token;
        address[] memory path;

        for (uint256 n = 0; n < _converterregistries.length; n++) {
            ibancorconverter converter = ibancorconverter(_converterregistries[n].latestconverteraddress(_token));
            tokencount = gettokencount(converter, connector_token_count);
            for (i = 0; i < tokencount; i++) {
                token = converter.connectortokens(i);
                if (token != _token) {
                    path = getpath(token, _converterregistries);
                    if (path.length > 0)
                        return getnewpath(path, _token, converter);
                }
            }
            tokencount = gettokencount(converter, reserve_token_count);
            for (i = 0; i < tokencount; i++) {
                token = converter.reservetokens(i);
                if (token != _token) {
                    path = getpath(token, _converterregistries);
                    if (path.length > 0)
                        return getnewpath(path, _token, converter);
                }
            }
        }

        return new address[](0);
    }

    
    function gettokencount(address _dest, bytes4 _funcselector) private view returns (uint256) {
        uint256[1] memory ret;
        bytes memory data = abi.encodewithselector(_funcselector);

        assembly {
            pop(staticcall(
                gas,           
                _dest,         
                add(data, 32), 
                mload(data),   
                ret,           
                32             
            ))
        }

        return ret[0];
    }

    
    function getnewpath(address[] memory _path, address _token, ibancorconverter _converter) private view returns (address[] memory) {
        address[] memory newpath = new address[](2 + _path.length);
        newpath[0] = _token;
        newpath[1] = ismarttokencontroller(_converter).token();
        for (uint256 k = 0; k < _path.length; k++)
            newpath[2 + k] = _path[k];
        return newpath;
    }

    
    function getshortestpath(address[] memory _sourcepath, address[] memory _targetpath) private pure returns (address[] memory) {
        if (_sourcepath.length > 0 && _targetpath.length > 0) {
            uint256 i = _sourcepath.length;
            uint256 j = _targetpath.length;
            while (i > 0 && j > 0 && _sourcepath[i  1] == _targetpath[j  1]) {
                i;
                j;
            }

            address[] memory path = new address[](i + j + 1);
            for (uint256 m = 0; m <= i; m++)
                path[m] = _sourcepath[m];
            for (uint256 n = j; n > 0; n)
                path[path.length  n] = _targetpath[n  1];
            return path;
        }

        return new address[](0);
    }
}
