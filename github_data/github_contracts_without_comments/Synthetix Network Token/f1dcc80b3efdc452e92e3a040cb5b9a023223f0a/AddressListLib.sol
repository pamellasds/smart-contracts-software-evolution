pragma solidity ^0.5.16;


library addresslistlib {
    struct addresslist {
        address[] elements;
        mapping(address => uint) indices;
    }

    function contains(addresslist storage list, address candidate) internal view returns (bool) {
        if (list.elements.length == 0) {
            return false;
        }
        uint index = list.indices[candidate];
        return index != 0 || list.elements[0] == candidate;
    }

    function getpage(
        addresslist storage list,
        uint index,
        uint pagesize
    ) internal view returns (address[] memory) {
        
        uint endindex = index + pagesize; 

        
        if (endindex > list.elements.length) {
            endindex = list.elements.length;
        }
        if (endindex <= index) {
            return new address[](0);
        }

        uint n = endindex  index; 
        address[] memory page = new address[](n);
        for (uint i; i < n; i++) {
            page[i] = list.elements[i + index];
        }
        return page;
    }

    function push(addresslist storage list, address element) internal {
        list.indices[element] = list.elements.length;
        list.elements.push(element);
    }

    function remove(addresslist storage list, address element) internal {
        require(contains(list, element), );
        
        uint index = list.indices[element];
        uint lastindex = list.elements.length  1; 
        if (index != lastindex) {
            
            address shiftedelement = list.elements[lastindex];
            list.elements[index] = shiftedelement;
            list.indices[shiftedelement] = index;
        }
        list.elements.pop();
        delete list.indices[element];
    }
}
