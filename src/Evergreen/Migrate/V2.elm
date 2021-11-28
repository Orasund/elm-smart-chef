module Evergreen.Migrate.V2 exposing (..)

import Dict
import Evergreen.V1.Gen.Model exposing (Model)
import Evergreen.V1.Shared
import Evergreen.V1.Types as Old
import Evergreen.V2.Gen.Model exposing (Model)
import Evergreen.V2.Shared
import Evergreen.V2.Types as New
import Lamdera.Migrations exposing (..)
import Random


frontendModel : Old.FrontendModel -> ModelMigration New.FrontendModel New.FrontendMsg
frontendModel old =
    ModelUnchanged


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg old =
    MsgUnchanged


toBackend : Old.ToBackend -> MsgMigration New.ToBackend New.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Old.BackendMsg -> MsgMigration New.BackendMsg New.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Old.ToFrontend -> MsgMigration New.ToFrontend New.FrontendMsg
toFrontend old =
    MsgUnchanged
