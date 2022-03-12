
pragma solidity 0.6.12;
import ;
import ;
import ;
import ;
import ;


contract conversionpathfinder is iconversionpathfinder, contractregistryclient {
    ierc20token public anchortoken;

    
    constructor(icontractregistry _registry) contractregistryclient(_registry) public {
    }

    
    function setanchortoken(ierc20token _anchortoken) public owneronly {
        anchortoken = _anchortoken;
    }

    
    function findpath(ierc20token _sourcetoken, ierc20token _targettoken) external override view returns (address[] memory) {
        iconverterregistry converterregistry = iconverterregistry(addressof(converter_registry));
        address[] memory sourcepath = getpath(_sourcetoken, converterregistry);
        address[] memory targetpath = getpath(_targettoken, converterregistry);
        return getshortestpath(sourcepath, targetpath);
    }

    
    function getpath(ierc20token _token, iconverterregistry _converterregistry) private view returns (address[] memory) {
        if (_token == anchortoken)
            return getinitialarray(address(_token));

        address[] memory anchors;
        if (_converterregistry.isanchor(address(_token)))
            anchors = getinitialarray(address(_token));
        else
            anchors = _converterregistry.getconvertibletokenanchors(_token);

        for (uint256 n = 0; n < anchors.length; n++) {
            iconverter converter = iconverter(payable(iconverteranchor(anchors[n]).owner()));
            uint256 connectortokencount = converter.connectortokencount();
            for (uint256 i = 0; i < connectortokencount; i++) {
                ierc20token connectortoken = converter.connectortokens(i);
                if (connectortoken != _token) {
                    address[] memory path = getpath(connectortoken, _converterregistry);
                    if (path.length > 0)
                        return getextendedarray(address(_token), anchors[n], path);
                }
            }
        }

        return new address[](0);
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

            uint256 length = 0;
            for (uint256 p = 0; p < path.length; p += 1) {
                for (uint256 q = p + 2; q < path.length  p % 2; q += 2) {
                    if (path[p] == path[q])
                        p = q;
                }
                path[length++] = path[p];
            }

            return getpartialarray(path, length);
        }

        return new address[](0);
    }

    
    function getinitialarray(address _item) private pure returns (address[] memory) {
        address[] memory array = new address[](1);
        array[0] = _item;
        return array;
    }

    
    function getextendedarray(address _item0, address _item1, address[] memory _array) private pure returns (address[] memory) {
        address[] memory array = new address[](2 + _array.length);
        array[0] = _item0;
        array[1] = _item1;
        for (uint256 i = 0; i < _array.length; i++)
            array[2 + i] = _array[i];
        return array;
    }

    
    function getpartialarray(address[] memory _array, uint256 _length) private pure returns (address[] memory) {
        address[] memory array = new address[](_length);
        for (uint256 i = 0; i < _length; i++)
            array[i] = _array[i];
        return array;
    }
}
