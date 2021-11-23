<template>
  <card title="Project Information">
    <div style="padding: 12px">
      <h2>{{ this.project.name }}</h2>
      <p>
        <b>Owner: </b>
        {{
          this.project.belongsToUser
            ? this.project.owner.username
            : this.project.owner.name
        }}
      </p>
      <div>
        <b>Contributors: </b>
        <p
          v-for="contributor in this.project.contributors"
          v-bind:key="contributor"
          style="padding-left: 10px"
        >
          {{ contributor }}
        </p>
      </div>
      <p><b>Balance: </b>{{ this.project.balance }} tokens</p>
      <b v-if="bounties.length > 0">Bounties: </b>
      <div v-for="bountie in this.bounties" v-bind:key="bountie.id">
        <resume-bountie
          :bountie="bountie"
          :projectId="project.id"
        ></resume-bountie>
      </div>
      <p>
        <a href="#" @click="openBountie"> Create a bountie </a>
      </p>
      <p>
        <a href="#" style="color: white" @click="sponsor = true">
          Sponsor this project
        </a>
      </p>
      <sponsor-project
        :id-project="this.project.id"
        :owner-address="this.project.ownerAddress"
        v-if="sponsor"
        @close="sponsor = false; updateProjectBalance"
      >
      </sponsor-project>
    </div>
  </card>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'
import ResumeBountie from '@/components/ResumeBountie.vue'
import SponsorProject from '@/components/SponsorProject.vue'

export default defineComponent({
  name: 'FullRecap',
  components: { Card, ResumeBountie, SponsorProject },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    return { address, contract, balance }
  },
  data() {
    const sponsor = false
    const id = this.$route.query.id
    const ownerAddress = this.$route.query.ownerAddress
    const project: any = {
      id: '',
      name: '',
      owner: {
        name: '',
        username: '',
        balance: 0,
      },
      ownerAddress: 'project.owner',
      belongsToUser: true,
      balance: 0,
      contributors: [],
    }
    const bounties: any[] = []
    return { sponsor, id, ownerAddress, project, bounties }
  },
  methods: {
    async openBountie() {
      this.$router.push({
        name: 'OpenBountie',
        query: {
          id: this.project.id,
          ownerAddress: this.project.ownerAddress,
        },
      })
    },
  },
  async mounted() {
    const { id, ownerAddress, contract } = this
    this.bounties = await contract.methods.getProjectBounties(id).call()
    const project = await contract.methods
      .getProjectById(ownerAddress, id)
      .call()
    let owner = project.belongsToUser
      ? await contract.methods.user(project.owner).call()
      : contract.methods.entreprise(project.owner).call()
    let contributors = []
    for (const address of project.contributors) {
      const contributor = await contract.methods.user(address).call()
      contributors.push(contributor.username)
    }
    this.project = {
      id: project.id,
      name: project.name,
      owner: {
        name: owner.name || undefined,
        username: owner.username || undefined,
        balance: owner.balance,
      },
      ownerAddress: project.owner,
      belongsToUser: project.belongsToUser,
      balance: project.balance,
      contributors: contributors,
    }
  },
})
</script>