locals {
  image_map = {

    bigip-14-1-2-6-0-0-2-all-1slot-2 = {
      "eu-de" = "r010-a7b2bdcd-37b5-4b12-90a1-2373817c21bf"
      "eu-fr2" = "r030-bf6775d0-4e66-4db7-8fd6-3520e6e9dad4"
    }

    bigip-14-1-2-6-0-0-2-ltm-1slot-2 = {
      "eu-de" = "r010-7c5d3ccf-f455-4408-911c-87f2908569d0"
      "eu-fr2" = "r030-88e0643f-9d53-4cba-97c2-c6483f5686f5"
    }

    bigip-15-1-0-4-0-0-6-all-1slot-2 = {
      "eu-de" = "r010-8019c15f-8057-439c-940f-1ae95beaf322"
      "eu-fr2" = "r030-1b714947-d072-4054-8cc7-d81f9f36ee74"
    }

    bigip-15-1-0-4-0-0-6-ltm-1slot-2 = {
      "eu-de" = "r010-ed6f2e7d-334e-497e-a9f2-078e8906bc39"
      "eu-fr2" = "r030-dbbf05c8-49f6-4f52-9446-1bd13fd3414d"
    }

    bigip-16-0-0-0-0-12-all-1slot-1 = {
      "eu-de" = "r010-2c49f39a-9bd5-4713-bdcf-be0b2d3dd075"
      "eu-fr2" = "r030-cbc05556-1c4f-4dd7-8d09-f602269f977b"
    }

    bigip-16-0-0-0-0-12-ltm-1slot-1 = {
      "eu-de" = "r010-0d498521-ff43-40ac-a62a-486708b588f8"
      "eu-fr2" = "r030-9e105731-dcd2-44dc-99f1-0fbe5bec3f2e"
    }

    bigip-14-1-2-6-0-0-2-all-1slot = {
      "us-south" = "r006-f0a8cba9-1e9e-4771-87ba-20b7fd33b16a"
      "us-east"  = "r014-eccb5c62-82d9-438c-b81e-716f3506700f"
      "eu-gb"    = "r018-72ee97b8-ffeb-4427-bd2a-fc60e4d2b6b5"
      "eu-de"    = "r010-cf56a548-d5ca-4833-b0a6-bde256140d93"
      "jp-tok"   = "r022-44656c7d-427c-4e06-9253-3224cd1df827"
      "eu-fr2"   = "r030-e75c31f5-0372-4b1f-a9a9-75b0b147b128"
    }

    bigip-14-1-2-6-0-0-2-ltm-1slot = {
      "us-south" = "r006-1ca34358-b1f0-44b1-bf9a-a8bd9837a672"
      "us-east"  = "r014-3c86e0bf-1026-4400-91f6-b4256d972ed5"
      "eu-gb"    = "r018-e717281f-5bd7-4e08-8d54-7b45ddfb12c7"
      "eu-de"    = "r010-e8022107-fea9-471b-ba6c-8b8f8e130ab9"
      "jp-tok"   = "r022-c7377896-c997-495a-88f7-033f827d6d8b"
      "eu-fr2"   = "r030-d244c128-5663-4df5-bd79-03124b393417"
    }

    bigip-15-1-0-4-0-0-6-all-1slot = {
      "us-south" = "r006-654bca9e-8e4d-46c2-980b-c52fdd2237f4"
      "us-east"  = "r014-d73926e1-3b82-413f-aecc-36710b59cf4b"
      "eu-gb"    = "r018-e02a17f1-90bc-494b-ab66-4f3e03c08b7d"
      "eu-de"    = "r010-3a06e044-56e8-4d45-a5c2-535a7b673a94"
      "jp-tok"   = "r022-a65002eb-ad05-4d56-bcb8-2d3fa14f9834"
      "eu-fr2"   = "r030-931c427f-1bae-4ce6-a242-6889e743639c"
    }

    bigip-15-1-0-4-0-0-6-ltm-1slot = {
      "us-south" = "r006-c176a319-39e3-4f24-82a1-6dd4f2fa58dc"
      "us-east"  = "r014-e2a4cc82-d935-4f3f-9042-21f64d18232c"
      "eu-gb"    = "r018-859e47fb-40db-4d72-9da7-2de4fc78d64c"
      "eu-de"    = "r010-cd996cda-53ce-4783-9e3a-03a18b9162ff"
      "jp-tok"   = "r022-36b57097-deba-49c2-bffb-f37c61c8e713"
      "eu-fr2"   = "r030-88b35711-82aa-45ae-b0e6-12785e7c2b55"
    }
  }
}

output "map_instance" {
  value = lookup(local.image_map[var.image_name], data.ibm_is_region.region.name)
}

