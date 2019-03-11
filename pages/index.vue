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
      <h2>Ethereumの情報</h2>
      <ul>
        <li>Coinbase: {{CoinBase}}</li>
        <li>アカウントリスト ({{Accounts.length}})</li>
        <li v-for="(account, index) in Accounts" :key="index">
          {{account}}
        </li>
      </ul>
      <br>
      <h2>プロジェクトの情報</h2>
      <ul>
        <li>メンバー一覧 ({{AllMembers.length}}人)</li>
        <li v-for="(member, index) in AllMembers" :key="index">
          <p>{{member}}</p>
        </li>
        <li>総貢献度数</li>
        <button type="button" class="btn btn-primary" @click="update_project_info">情報更新</button>
      </ul>
      <br>
      <br>
      <h2>あなたの情報</h2>
      <ul>
        <li>
          address: {{CoinBase}}
        </li>
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

export default {
  data() {
    return {
      CoinBase: "wait...",
      Accounts: [],
      AmIMember: false,
      isWaitingForJoinAddress: false,
      AllMembers: [],
      PayAmount: "",
      JoinAnotherAddress: "",
      VoteForAnotherAddress: '',
      Message: "",
    }
  },
  beforeMount(){
    console.log('window.ethereum: ', window.ethereum);
    console.log('ethereum: ', ethereum);
    web3 = new Web3(window.ethereum);
    console.log('web3:', web3);
    ethereum.enable().then(()=>{
      let contractAddress = "0xb89A028C868186B1568f1cA109dCFA191eac5b32";
      let MyContract = web3.eth.contract(abi);
      contractInstance = MyContract.at(contractAddress);
      console.log("contractInstance:", contractInstance);
      console.log("contractInstance:", contractInstance);
      console.log('contractInstance.transactionHash:', contractInstance.transactionHash); //null
      console.log('contractInstance.address:', contractInstance.address); //contractAddress

      this.CoinBase = web3.eth.coinbase;
      this.Accounts = web3.eth.accounts;
      this.update_project_info();
    });
  },
  methods: {
    update_project_info(){
      this.am_i_member();
      this.all_members();
      this.am_i_waiting_for_join_address();
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
        else { this.Message = "参加申請をしました\n" + this.Message; }
      });
    },
    request_to_join_another(){
      console.log('this.JoinAnotherAddress: ', this.JoinAnotherAddress, web3.isAddress(this.JoinAnotherAddress));
      contractInstance.requestToJoinAnother.sendTransaction(this.JoinAnotherAddress, (err, transactionHash) => {
        if (err) { console.log(err); }
        else { this.Message = "参加申請をしました\n" + this.Message; }
      });
    },
    vote_for_member_waiting_for_join(){
      contractInstance.voteForMemberWaitingForJoin.sendTransaction(this.VoteForAnotherAddress,{
        value: 0,
        gas: 200000,
        nonce: 1,
      }, (err, txhash)=>{
        if (err) { console.log(err); }
        else { this.Message = this.VoteForAnotherAddress + "に投票しました\n" + this.Message; }
      });
    },
    pay_to_project(){
      console.log("pay_to_project: ", contractInstance);
      web3.eth.sendTransaction({
        value: web3.utils.toWei(this.PayAmount.toString(), 'ether'),
        gas:                200000,
        from: "0x9c4E9Ac07D994F1Bf0b6CCADF015544449210C21"
      }, (err, hash) => {
        if (err) { console.log(err); }
        else {
          console.log('txHash: ', hash); //"0xc00d7771c68ee0636beb7e36939f7fc2ec5715fdfd931f9dfd5a407295baf1c2"
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

