// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    //state variables
    address payable public immutable feeAccount; //the account that receive the fees.
    uint256 public immutable feePercent; // the fee percentage on sales
    uint256 public itemCount;

    constructor(uint256 _feePercent) {
        feeAccount = payable(msg.sender);
        feePercent = _feePercent;
    }

    struct Item {
        uint256 itemId;
        IERC721 nft;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool sold;
    }

    event Offered(
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller
    );

    event Bought (
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller,
        address indexed buyer
    );

    //itemId -> Item
    mapping(uint256 => Item) public items;

    function makeItem(
        IERC721 _nft,
        uint256 _tokenId,
        uint256 _price
    ) external nonReentrant {
        require(_price > 0, "Price must be greater than zero");
        //Increment itemCount
        itemCount++;
        //transfter nft to this contract
        _nft.transferFrom(msg.sender, address(this), _tokenId);

        // add new item to the mapping record
        items[itemCount] = Item(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );

        //emit event
        emit Offered(itemCount, address(_nft), _tokenId, _price, msg.sender);
    }

    function purchaseItem(uint256 _itemId) external payable nonReentrant {
        uint _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "Item doesn't exist");
        require(msg.value >= _totalPrice, "Not enough ether to cover item price and market fee");
        require(!item.sold, "Item already sold");
        // pay seller and fee account
        item.seller.transfer(item.price);
        feeAccount.transfer(_totalPrice - item.price);
        //update item to sold
        item.sold = true;
        item.nft.transferFrom(address(this), msg.sender, item.tokenId);

       //emit bought event
       emit Bought (
        _itemId,
        address(item.nft),
        item.tokenId,
        item.price,
        item.seller,
        msg.sender,
       );
    }

    function getTotalPrice(uint256 _itemId) public view returns (uint256) {
      return(items[_itemId].price * (100 + feePercent)/100);
    }
}
