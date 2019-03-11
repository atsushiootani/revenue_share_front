<template>
  <section class="container">
    <div>
      <h1 class="title">
        revenue share contract
      </h1>
      <h2 class="subtitle">
        報酬分配を自動化して、みんなのお金をクリアに！
      </h2>
      <br>
      <!--<h2>Ethereumの情報</h2>
      <ul>
        <li>Coinbase: {{CoinBase}}</li>
        <li>アカウントリスト ({{Accounts.length}})</li>
        <li v-for="(account, index) in Accounts" :key="index">
          {{account}}
        </li>
      </ul>-->
      <br>
      <h2>プロジェクトの情報</h2>
      <ul>
        <li>メンバー一覧 ({{AllMembers.length}}人)</li>
        <li v-for="(member, index) in AllMembers" :key="index">
          <p>{{member}}</p>
        </li>
        <li>総貢献度数 {{TotalContributeValue}}</li>
        <button type="button" class="btn btn-primary" @click="update_project_info">情報更新</button>
      </ul>
      <br>
      <br>
      <h2>あなたの情報</h2>
      <ul>
        <li>address: {{CoinBase}}</li>
        <li>残高: {{Balance}} Ether </li>
        <template v-if="AmIMember">
          <li>あなたはメンバーです</li>
          <li>
            <input type="text" class="form-control" placeholder="招待したいaddress" v-model="JoinAnotherAddress">
            <button type="button" class="btn btn-primary" @click="request_to_join_another">メンバーに招待する</button>
          </li>
          <li>
            <input type="text" class="form-control" placeholder="追加に賛成したいaddress" v-model="VoteForAnotherAddress">
            <button type="button" class="btn btn-primary" @click="vote_for_member_waiting_for_join">メンバー追加に賛成する</button>
          </li>
          <li>
            貢献度： {{MyContributeValue}}
          </li>
          <li>
            <input type="text" class="form-control" placeholder="貢献度を数値で" v-model="ContributeValue">
            <button type="button" class="btn btn-primary" @click="request_to_contribute">貢献度を申請する</button>
          </li>
          <li>投票可能な貢献度一覧(自分の貢献には投票できません)</li>
          <li v-for="(cid, index) in this.VotableContributeIds" :key="index">
            id: {{cid}}
          </li>
          <li>
            <input type="text" class="form-control" placeholder="承認する貢献のid" v-model="VoteContributeId">
            <button type="button" class="btn btn-primary" @click="vote_for_contribute">貢献を承認する</button>
          </li>
        </template>
        <template v-else-if="isWaitingForJoinAddress">
          <li>あなたはメンバー追加待ち中です</li>
          <li>参加が許可されるまでお待ちください</li>
        </template>
        <template v-else>
          <li>あなたはメンバーではありません</li>
          <li>
            <button type="button" class="btn btn-primary" @click="request_to_join">メンバーとして参加する</button>
          </li>
        </template>
      </ul>
      <br>
      <br>
      <h2>プロジェクト外メンバーメニュー</h2>
      <ul>
        このプロジェクトに送金する
        <input type="text" class="form-control" placeholder="ether" v-model="PayAmount">
        <button type="button" class="btn btn-primary" @click="pay_to_project">送金</button>
      </ul>
      <br>
      <br>
      <p>{{Message}}</p>
    </div>
  </section>
</template>

<script>
import AppLogo from '~/components/AppLogo.vue'
//import web3 from '../helper/web3';
//import contractInstance from '../helper/contract';
import abi from '../helper/abi';

var web3;
var contractInstance;
let contractAddress = "0xaD2d34fEDC73727B619310e5C52C1edD7258E96D";

export default {
  data() {
    return {
      CoinBase: "wait...",
      Accounts: [],
      Balance: '',
      AmIMember: false,
      isWaitingForJoinAddress: false,
      AllMembers: [],
      PayAmount: "",
      JoinAnotherAddress: "",
      VoteForAnotherAddress: '',
      VotableContributeIds: [],
      MyContributeValue: 0,
      ContributeValue: '',
      VoteContributeId: '',
      TotalContributeValue: 0,
      Message: "",
    }
  },
  beforeMount(){
    console.log('window.ethereum: ', window.ethereum);
    console.log('ethereum: ', ethereum);
    web3 = new Web3(window.ethereum);
    console.log('web3:', web3);
    ethereum.enable().then(()=>{
      let MyContract = web3.eth.contract(abi);
      contractInstance = MyContract.at(contractAddress);
      console.log("contractInstance:", contractInstance);
      console.log("contractInstance:", contractInstance);
      console.log('contractInstance.transactionHash:', contractInstance.transactionHash); //null
      console.log('contractInstance.address:', contractInstance.address); //contractAddress

      this.CoinBase = web3.eth.coinbase;
      this.Accounts = web3.eth.accounts;
      this.update_project_info();

      contractInstance.MemberAdded((err, event)=>{
        if (err) { console.log(err); }
        else {
          console.log(event);
          this.Message = event.args.member + "がメンバーになりました！\n" + this.Message;
        }
      });

      contractInstance.ContributeAdded((err,event)=>{
        if (err) { console.log(err); }
        else {
          console.log(event);
          this.Message = "貢献(id=" + event.args.contributeId + ")が承認されました！\n" + this.Message;
        }
      });

      contractInstance.Distributed((err, event)=>{
        if (err) { console.log(err); }
        else{
          console.log(event);
          this.Message = "" + event.args.member + "に" + web3.fromWei(event.args.fee, 'ether') + "Etherが分配されました！\n" + this.Message;
        }
      });
    });
  },
  methods: {
    update_project_info(){
      this.am_i_member();
      this.all_members();
      this.get_balance();
      this.am_i_waiting_for_join_address();
      this.total_contribute_value();
      if (this.AmIMember){
        this.contributes_of_member();
        this.all_waiting_contributes();
      }
    },
    get_balance(){
      web3.eth.getBalance(this.CoinBase, (err, result)=>{
        if (err) { console.log(err); }
        else { this.Balance = web3.fromWei(result, 'ether'); }
      });
    },
    all_members(){
      contractInstance.allMembers.call((err,result)=>{
        if (err) { console.log(err); }
        else { this.AllMembers = result; }
      });
    },
    am_i_member(){
      contractInstance.amIMember.call((err, result)=>{
        if (err) { console.log(err); }
        else { this.AmIMember  = result; }
      });
    },
    am_i_waiting_for_join_address(){
      contractInstance.isWaitingForJoinAddress.call(this.CoinBase, (err, result)=>{
        if (err) { console.log(err); }
        else { this.isWaitingForJoinAddress = result; }
      });
    },
    request_to_join(){
      console.log("request_to_join: ", contractInstance);
      contractInstance.requestToJoin.sendTransaction({
        value: 0,
        gas: 200000,
      }, (err, transactionHash) =>{
        if (err) { console.log(err); }
        else {
          this.Message = "参加申請をしました\n" + this.Message;
          this.update_project_info();
        }
      });
    },
    request_to_join_another(){
      console.log('this.JoinAnotherAddress: ', this.JoinAnotherAddress, web3.isAddress(this.JoinAnotherAddress));
      contractInstance.requestToJoinAnother.sendTransaction(this.JoinAnotherAddress, (err, transactionHash) => {
        if (err) { console.log(err); }
        else {
          this.Message = "参加申請をしました\n" + this.Message;
          this.update_project_info();
        }
      });
    },
    vote_for_member_waiting_for_join(){
      contractInstance.voteForMemberWaitingForJoin.sendTransaction(this.VoteForAnotherAddress,{
        value: 0,
        gas: 200000,
      }, (err, txhash)=>{
        if (err) { console.log(err); }
        else {
          this.Message = this.VoteForAnotherAddress + "に投票しました\n" + this.Message;
          this.update_project_info();
        }
      });
    },
    all_waiting_contributes(){
      contractInstance.allWaitingContributes.call((err, result)=>{
        if (err) { console.log(err); }
        else { console.log('contributes:', result); this.VotableContributeIds = result; }
      });
    },
    contributes_of_member(){
      contractInstance.contributeValue.call(this.CoinBase, (err, result)=>{
        if (err) { console.log(err); }
        else {
          this.MyContributeValue = result;
        }
      });
    },
    request_to_contribute(){
      contractInstance.requestToContribute.sendTransaction(this.ContributeValue, {
        value: 0,
        gas: 200000,
      }, (err, txhash)=>{
        if (err) { console.log(err); }
        else {
          this.Message = "貢献度の申請を行いました\n" + this.Message;
          this.ContributeValue = '';
        }
      });
    },
    vote_for_contribute(){
      contractInstance.voteForContribute.sendTransaction(this.VoteContributeId, {
        value: 0,
        gas: 200000,
      }, (err, txhash)=>{
        if (err) { console.log(err); }
        else {
          this.Message = "貢献度に投票しました\n" + this.Message;
          this.VoteContributeId = '';
        }
      });
    },
    total_contribute_value(){
      contractInstance.totalContributeValue.call((err, result)=>{
        if (err) { console.log(err); }
        else { this.TotalContributeValue = result; }
      });
    },
    pay_to_project(){
      console.log("pay_to_project: ", contractInstance);
      contractInstance.fee.sendTransaction({
        value: web3.toWei(this.PayAmount, 'ether'),
        gas: 200000,
      }, (err, txhash)=>{
        if (err) { console.log(err); }
        else {
          this.Message = this.PayAmount + "Ether送金しました\n" + this.Message;
          this.PayAmount = '';
        }
      });
    }
  }
}


</script>

<style>
.container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
}

.title {
  font-family: "Quicksand", "Source Sans Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; /* 1 */
  display: block;
  font-weight: 300;
  font-size: 100px;
  color: #35495e;
  letter-spacing: 1px;
}

.subtitle {
  font-weight: 300;
  font-size: 42px;
  color: #526488;
  word-spacing: 5px;
  padding-bottom: 15px;
}

.links {
  padding-top: 15px;
}
</style>

