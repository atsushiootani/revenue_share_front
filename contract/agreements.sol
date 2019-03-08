pragma solidity ^0.5.2;
import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Agreements{

    using SafeMath for uint256; //TODO: 256以外も

    /**************** event ****************/
    
    /// メンバーが追加された
    event MemberAdded(address member);

    /// 貢献度が承認された
    event ContributeAdded(uint contributeId);

    /// 分配が実行された
    event Distributed(address member, uint fee);

    /**************** 変数 ****************/

    /// メンバーの人数
    address payable[] public members;
    uint8 public memberCount;

    /// 参加待ちメンバー
    mapping (address => bool) membersWaitingForJoin;
    
    /// 参加待ちメンバーへの投票者・投票数
    mapping (address => mapping (address => bool)) votesForMembersWaitingForJoin;
    mapping (address => uint8) voteCountForMembersWaitingForJoin;

    /// メンバーごとの貢献度
    mapping (address => uint) public contributesOfMember;

    /// 貢献度
    struct Contribute{
        uint id;
        uint16 value;       //貢献度
        uint8 votedCount;   //承認投票総数
        bool approved;      //承認されたかどうか
        address member;     //この貢献を行ったメンバー
        mapping (address => bool) votedMembers; //承認投票者のリスト
    }

    /// 貢献度承認待ち
    Contribute[] public waitingContributes;

    /**************** modifier ****************/
    
    /// メンバーであること
    modifier isMember(address _addr){
        require(contributesOfMember[_addr] != 0);
        _;
    }
    
    /// メンバーでないこと
    modifier isNotMember(address _addr){
        require(contributesOfMember[_addr] == 0);
        _;
    }

    /// 参加待ち状態であること
    modifier isWaitingForJoin(address _addr){
        require(membersWaitingForJoin[_addr] == true);
        _;
    }
    
    /// 参加待ち状態でないこと
    modifier isNotWaitingForJoin(address _addr){
        require(membersWaitingForJoin[_addr] == false);
        _;
    }
    
    /// 参加要求に投票していないこと
    modifier notYetVotedForJoin(address _voter, address _addr){
        require(votesForMembersWaitingForJoin[_voter][_addr] == false);
        _;
    }

    /// 貢献が投票待ち状態であること
    modifier isWaitingForApproved(uint _id){
        require(_id >= 0 && _id < waitingContributes.length);
        require(waitingContributes[_id].approved == false);
        _;
    }

    /// 自分の貢献であること
    modifier isMyContribute(address _member, uint _id){
        require(_id >= 0 && _id < waitingContributes.length);
        require(waitingContributes[_id].member == _member);
        _;
    }

    /// 自分の貢献でないこと
    modifier isNotMyContribute(address _member, uint _id){
        require(_id >= 0 && _id < waitingContributes.length);
        require(waitingContributes[_id].member != _member);
        _;
    }
    
    /// 貢献に投票していないこと
    modifier notYetVotedForApprove(address _member, uint _id){
        require(_id >= 0 && _id < waitingContributes.length);
        require(waitingContributes[_id].votedMembers[_member] == false);
        _;
    }

    /**************** function members ****************/
    
    /// 自分はメンバー？（動作確認用）
    function amIMember() public view returns(bool)
    {
        return contributesOfMember[msg.sender] != 0;
    }

    /// 自分の参加要求を出す
    function requestToJoin() external
        isNotMember(msg.sender)
        isNotWaitingForJoin(msg.sender)
    {
        membersWaitingForJoin[msg.sender] = true;
        
        //暫定措置として、最初の1人は即時にメンバーになれる
        if (memberCount == 0) {
            _proceedMember(msg.sender);
        }
    }

    /// 他人の参加要求を出す
    function requestToJoinAnother(address payable _memberRequestToJoin) external
        isMember(msg.sender)
        isNotMember(_memberRequestToJoin)
        isNotWaitingForJoin(_memberRequestToJoin)
    {
        membersWaitingForJoin[_memberRequestToJoin] = true;

        //参加要求を出すと同時に、投票も行う
        voteForMemberWaitingForJoin(_memberRequestToJoin);
    }

    /// 参加承認に投票する
    function voteForMemberWaitingForJoin(address payable _memberWaitingForJoin) public
        isMember(msg.sender)
        isWaitingForJoin(_memberWaitingForJoin)
        notYetVotedForJoin(msg.sender, _memberWaitingForJoin)
    {
        votesForMembersWaitingForJoin[msg.sender][_memberWaitingForJoin] = true;
        voteCountForMembersWaitingForJoin[_memberWaitingForJoin]++;
        
        //過半数に達したらメンバーに追加
        if (voteCountForMembersWaitingForJoin[_memberWaitingForJoin] > memberCount / 2){
            _proceedMember(_memberWaitingForJoin);
        }
    }
    
    /// 参加させる
    function _proceedMember(address payable _waitingMember) internal
        isNotMember(_waitingMember)
    {
        members.push(_waitingMember);
        memberCount++;
        contributesOfMember[_waitingMember] = 1; //フラグ代わりの初期値。貢献度計算時には減算する
        delete membersWaitingForJoin[_waitingMember];
        
        emit MemberAdded(_waitingMember);
    }

    /**************** function contributes ****************/

    /// 自分の貢献度を宣言する
    function requestToContribute(uint16 _value) external
        isMember(msg.sender)
        returns (uint)
    {
        uint id = waitingContributes.push(Contribute(waitingContributes.length, _value, 0, false, msg.sender)) - 1 ;
        
        //同時に投票も行う
        voteForContribute(id);

        return id;
    }
    
    /// 貢献度に投票する
    function voteForContribute(uint _contributeId) public
        isMember(msg.sender)
        isWaitingForApproved(_contributeId)
        notYetVotedForApprove(msg.sender, _contributeId)
    {
        waitingContributes[_contributeId].votedMembers[msg.sender] = true;
        waitingContributes[_contributeId].votedCount++;

        /// 過半数を超えたら、貢献を承認
        if (waitingContributes[_contributeId].votedCount > memberCount / 2) {
            _proceedContribute(_contributeId);
        }
    }
    
    /// 貢献を承認
    function _proceedContribute(uint _contributeId) internal
        isWaitingForApproved(_contributeId)
    {
        Contribute storage contribute = waitingContributes[_contributeId];
        contribute.approved = true;
        contributesOfMember[contribute.member] = contributesOfMember[contribute.member].add(contribute.value);
        
        emit ContributeAdded(_contributeId);
    }
    
    /// 総貢献度の算出
    function totalContributeValue() public view returns (uint)
    {
        uint total = 0;
        for (uint i = 0; i < memberCount; ++i) {
            address member = members[i];
            total = total.add(contributesOfMember[member].sub(1)); //初期値の分減らす
        }
        return total;
    }

    /**************** function revenue share ****************/

    /// 分配可能資金
    function deposit() public view returns (uint){
        return address(this).balance;
    }

    /// 入金(fallbackがあるので別にいらない？)
    function fee() external payable {
        _revenueShare();
    }

    /// 分配
    function _revenueShare() internal {
        uint amount = deposit();
        if (amount <= 0){
            return;
        }

        uint total = totalContributeValue();
        if (total <= 0) {
            return;
        }

        for (uint i = 0; i < memberCount; ++i) {
            address payable member = members[i];
            
            uint contribute = contributesOfMember[member].sub(1); //初期値の分を減らす
            if (contribute > 0) {
                uint memberFee = amount.mul(contribute).div(total);
                //ここで送金
                member.transfer(memberFee);
                emit Distributed(member, memberFee);
            }
        }
    }

    /// fallback(入金処理だけ行う)
    function() external payable {
        require(msg.data.length == 0);
        _revenueShare();
    }
}

