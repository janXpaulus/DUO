// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.28.1
// 	protoc        v3.21.12
// source: duo_service.proto

package pb

import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

var File_duo_service_proto protoreflect.FileDescriptor

var file_duo_service_proto_rawDesc = []byte{
	0x0a, 0x11, 0x64, 0x75, 0x6f, 0x5f, 0x73, 0x65, 0x72, 0x76, 0x69, 0x63, 0x65, 0x2e, 0x70, 0x72,
	0x6f, 0x74, 0x6f, 0x12, 0x02, 0x70, 0x62, 0x1a, 0x0a, 0x67, 0x61, 0x6d, 0x65, 0x2e, 0x70, 0x72,
	0x6f, 0x74, 0x6f, 0x1a, 0x0a, 0x76, 0x6f, 0x69, 0x64, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x1a,
	0x13, 0x61, 0x75, 0x74, 0x68, 0x5f, 0x6d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65, 0x73, 0x2e, 0x70,
	0x72, 0x6f, 0x74, 0x6f, 0x1a, 0x0b, 0x6c, 0x6f, 0x62, 0x62, 0x79, 0x2e, 0x70, 0x72, 0x6f, 0x74,
	0x6f, 0x1a, 0x10, 0x75, 0x73, 0x65, 0x72, 0x5f, 0x73, 0x74, 0x61, 0x74, 0x65, 0x2e, 0x70, 0x72,
	0x6f, 0x74, 0x6f, 0x1a, 0x0c, 0x66, 0x72, 0x69, 0x65, 0x6e, 0x64, 0x2e, 0x70, 0x72, 0x6f, 0x74,
	0x6f, 0x1a, 0x12, 0x6e, 0x6f, 0x74, 0x69, 0x66, 0x69, 0x63, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x2e,
	0x70, 0x72, 0x6f, 0x74, 0x6f, 0x32, 0xeb, 0x08, 0x0a, 0x0a, 0x44, 0x55, 0x4f, 0x53, 0x65, 0x72,
	0x76, 0x69, 0x63, 0x65, 0x12, 0x37, 0x0a, 0x08, 0x52, 0x65, 0x67, 0x69, 0x73, 0x74, 0x65, 0x72,
	0x12, 0x13, 0x2e, 0x70, 0x62, 0x2e, 0x52, 0x65, 0x67, 0x69, 0x73, 0x74, 0x65, 0x72, 0x52, 0x65,
	0x71, 0x75, 0x65, 0x73, 0x74, 0x1a, 0x14, 0x2e, 0x70, 0x62, 0x2e, 0x52, 0x65, 0x67, 0x69, 0x73,
	0x74, 0x65, 0x72, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x22, 0x00, 0x12, 0x46, 0x0a,
	0x15, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x4c, 0x6f, 0x67, 0x69, 0x6e, 0x43, 0x68, 0x61,
	0x6c, 0x6c, 0x65, 0x6e, 0x67, 0x65, 0x12, 0x10, 0x2e, 0x70, 0x62, 0x2e, 0x4c, 0x6f, 0x67, 0x69,
	0x6e, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x1a, 0x19, 0x2e, 0x70, 0x62, 0x2e, 0x4c, 0x6f,
	0x67, 0x69, 0x6e, 0x43, 0x68, 0x61, 0x6c, 0x6c, 0x65, 0x6e, 0x67, 0x65, 0x52, 0x65, 0x71, 0x75,
	0x65, 0x73, 0x74, 0x22, 0x00, 0x12, 0x47, 0x0a, 0x14, 0x53, 0x75, 0x62, 0x6d, 0x69, 0x74, 0x4c,
	0x6f, 0x67, 0x69, 0x6e, 0x43, 0x68, 0x61, 0x6c, 0x6c, 0x65, 0x6e, 0x67, 0x65, 0x12, 0x1a, 0x2e,
	0x70, 0x62, 0x2e, 0x4c, 0x6f, 0x67, 0x69, 0x6e, 0x43, 0x68, 0x61, 0x6c, 0x6c, 0x65, 0x6e, 0x67,
	0x65, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x1a, 0x11, 0x2e, 0x70, 0x62, 0x2e, 0x4c,
	0x6f, 0x67, 0x69, 0x6e, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x22, 0x00, 0x12, 0x39,
	0x0a, 0x11, 0x53, 0x65, 0x6e, 0x64, 0x46, 0x72, 0x69, 0x65, 0x6e, 0x64, 0x52, 0x65, 0x71, 0x75,
	0x65, 0x73, 0x74, 0x12, 0x18, 0x2e, 0x70, 0x62, 0x2e, 0x46, 0x72, 0x69, 0x65, 0x6e, 0x64, 0x52,
	0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x1a, 0x08, 0x2e,
	0x70, 0x62, 0x2e, 0x76, 0x6f, 0x69, 0x64, 0x22, 0x00, 0x12, 0x42, 0x0a, 0x19, 0x53, 0x65, 0x6e,
	0x64, 0x46, 0x72, 0x69, 0x65, 0x6e, 0x64, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x52, 0x65,
	0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x12, 0x19, 0x2e, 0x70, 0x62, 0x2e, 0x46, 0x72, 0x69, 0x65,
	0x6e, 0x64, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73,
	0x65, 0x1a, 0x08, 0x2e, 0x70, 0x62, 0x2e, 0x76, 0x6f, 0x69, 0x64, 0x22, 0x00, 0x12, 0x42, 0x0a,
	0x11, 0x47, 0x65, 0x74, 0x46, 0x72, 0x69, 0x65, 0x6e, 0x64, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73,
	0x74, 0x73, 0x12, 0x14, 0x2e, 0x70, 0x62, 0x2e, 0x54, 0x6f, 0x6b, 0x65, 0x6e, 0x4f, 0x6e, 0x6c,
	0x79, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x1a, 0x15, 0x2e, 0x70, 0x62, 0x2e, 0x46, 0x72,
	0x69, 0x65, 0x6e, 0x64, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x4c, 0x69, 0x73, 0x74, 0x22,
	0x00, 0x12, 0x37, 0x0a, 0x0d, 0x47, 0x65, 0x74, 0x46, 0x72, 0x69, 0x65, 0x6e, 0x64, 0x4c, 0x69,
	0x73, 0x74, 0x12, 0x14, 0x2e, 0x70, 0x62, 0x2e, 0x54, 0x6f, 0x6b, 0x65, 0x6e, 0x4f, 0x6e, 0x6c,
	0x79, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x1a, 0x0e, 0x2e, 0x70, 0x62, 0x2e, 0x46, 0x72,
	0x69, 0x65, 0x6e, 0x64, 0x4c, 0x69, 0x73, 0x74, 0x22, 0x00, 0x12, 0x33, 0x0a, 0x0c, 0x44, 0x65,
	0x6c, 0x65, 0x74, 0x65, 0x46, 0x72, 0x69, 0x65, 0x6e, 0x64, 0x12, 0x17, 0x2e, 0x70, 0x62, 0x2e,
	0x44, 0x65, 0x6c, 0x65, 0x74, 0x65, 0x46, 0x72, 0x69, 0x65, 0x6e, 0x64, 0x52, 0x65, 0x71, 0x75,
	0x65, 0x73, 0x74, 0x1a, 0x08, 0x2e, 0x70, 0x62, 0x2e, 0x76, 0x6f, 0x69, 0x64, 0x22, 0x00, 0x12,
	0x3d, 0x0a, 0x12, 0x53, 0x74, 0x61, 0x74, 0x75, 0x73, 0x43, 0x68, 0x61, 0x6e, 0x67, 0x65, 0x53,
	0x74, 0x72, 0x65, 0x61, 0x6d, 0x12, 0x17, 0x2e, 0x70, 0x62, 0x2e, 0x53, 0x74, 0x61, 0x74, 0x75,
	0x73, 0x43, 0x68, 0x61, 0x6e, 0x67, 0x65, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x1a, 0x08,
	0x2e, 0x70, 0x62, 0x2e, 0x76, 0x6f, 0x69, 0x64, 0x22, 0x00, 0x28, 0x01, 0x30, 0x01, 0x12, 0x43,
	0x0a, 0x15, 0x47, 0x65, 0x74, 0x4e, 0x6f, 0x74, 0x69, 0x66, 0x69, 0x63, 0x61, 0x74, 0x69, 0x6f,
	0x6e, 0x53, 0x74, 0x72, 0x65, 0x61, 0x6d, 0x12, 0x14, 0x2e, 0x70, 0x62, 0x2e, 0x54, 0x6f, 0x6b,
	0x65, 0x6e, 0x4f, 0x6e, 0x6c, 0x79, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x1a, 0x10, 0x2e,
	0x70, 0x62, 0x2e, 0x4e, 0x6f, 0x74, 0x69, 0x66, 0x69, 0x63, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x22,
	0x00, 0x30, 0x01, 0x12, 0x3a, 0x0a, 0x0b, 0x43, 0x72, 0x65, 0x61, 0x74, 0x65, 0x4c, 0x6f, 0x62,
	0x62, 0x79, 0x12, 0x16, 0x2e, 0x70, 0x62, 0x2e, 0x43, 0x72, 0x65, 0x61, 0x74, 0x65, 0x4c, 0x6f,
	0x62, 0x62, 0x79, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x1a, 0x0f, 0x2e, 0x70, 0x62, 0x2e,
	0x4c, 0x6f, 0x62, 0x62, 0x79, 0x53, 0x74, 0x61, 0x74, 0x75, 0x73, 0x22, 0x00, 0x30, 0x01, 0x12,
	0x3d, 0x0a, 0x11, 0x43, 0x68, 0x61, 0x6e, 0x67, 0x65, 0x53, 0x74, 0x61, 0x63, 0x6b, 0x44, 0x65,
	0x76, 0x69, 0x63, 0x65, 0x12, 0x1c, 0x2e, 0x70, 0x62, 0x2e, 0x43, 0x68, 0x61, 0x6e, 0x67, 0x65,
	0x53, 0x74, 0x61, 0x63, 0x6b, 0x44, 0x65, 0x76, 0x69, 0x63, 0x65, 0x52, 0x65, 0x71, 0x75, 0x65,
	0x73, 0x74, 0x1a, 0x08, 0x2e, 0x70, 0x62, 0x2e, 0x76, 0x6f, 0x69, 0x64, 0x22, 0x00, 0x12, 0x36,
	0x0a, 0x09, 0x4a, 0x6f, 0x69, 0x6e, 0x4c, 0x6f, 0x62, 0x62, 0x79, 0x12, 0x14, 0x2e, 0x70, 0x62,
	0x2e, 0x4a, 0x6f, 0x69, 0x6e, 0x4c, 0x6f, 0x62, 0x62, 0x79, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73,
	0x74, 0x1a, 0x0f, 0x2e, 0x70, 0x62, 0x2e, 0x4c, 0x6f, 0x62, 0x62, 0x79, 0x53, 0x74, 0x61, 0x74,
	0x75, 0x73, 0x22, 0x00, 0x30, 0x01, 0x12, 0x4c, 0x0a, 0x0f, 0x44, 0x69, 0x73, 0x63, 0x6f, 0x6e,
	0x6e, 0x65, 0x63, 0x74, 0x4c, 0x6f, 0x62, 0x62, 0x79, 0x12, 0x1a, 0x2e, 0x70, 0x62, 0x2e, 0x44,
	0x69, 0x73, 0x63, 0x6f, 0x6e, 0x6e, 0x65, 0x63, 0x74, 0x4c, 0x6f, 0x62, 0x62, 0x79, 0x52, 0x65,
	0x71, 0x75, 0x65, 0x73, 0x74, 0x1a, 0x1b, 0x2e, 0x70, 0x62, 0x2e, 0x44, 0x69, 0x73, 0x63, 0x6f,
	0x6e, 0x6e, 0x65, 0x63, 0x74, 0x4c, 0x6f, 0x62, 0x62, 0x79, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e,
	0x73, 0x65, 0x22, 0x00, 0x12, 0x2d, 0x0a, 0x09, 0x53, 0x74, 0x61, 0x72, 0x74, 0x47, 0x61, 0x6d,
	0x65, 0x12, 0x14, 0x2e, 0x70, 0x62, 0x2e, 0x54, 0x6f, 0x6b, 0x65, 0x6e, 0x4f, 0x6e, 0x6c, 0x79,
	0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x1a, 0x08, 0x2e, 0x70, 0x62, 0x2e, 0x76, 0x6f, 0x69,
	0x64, 0x22, 0x00, 0x12, 0x3a, 0x0a, 0x0c, 0x47, 0x65, 0x74, 0x47, 0x61, 0x6d, 0x65, 0x53, 0x74,
	0x61, 0x74, 0x65, 0x12, 0x17, 0x2e, 0x70, 0x62, 0x2e, 0x47, 0x65, 0x74, 0x47, 0x61, 0x6d, 0x65,
	0x53, 0x74, 0x61, 0x74, 0x65, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x1a, 0x0d, 0x2e, 0x70,
	0x62, 0x2e, 0x47, 0x61, 0x6d, 0x65, 0x53, 0x74, 0x61, 0x74, 0x65, 0x22, 0x00, 0x30, 0x01, 0x12,
	0x3a, 0x0a, 0x0f, 0x47, 0x65, 0x74, 0x50, 0x6c, 0x61, 0x79, 0x65, 0x72, 0x53, 0x74, 0x72, 0x65,
	0x61, 0x6d, 0x12, 0x10, 0x2e, 0x70, 0x62, 0x2e, 0x50, 0x6c, 0x61, 0x79, 0x65, 0x72, 0x41, 0x63,
	0x74, 0x69, 0x6f, 0x6e, 0x1a, 0x0f, 0x2e, 0x70, 0x62, 0x2e, 0x50, 0x6c, 0x61, 0x79, 0x65, 0x72,
	0x53, 0x74, 0x61, 0x74, 0x65, 0x22, 0x00, 0x28, 0x01, 0x30, 0x01, 0x12, 0x36, 0x0a, 0x0e, 0x47,
	0x65, 0x74, 0x53, 0x74, 0x61, 0x63, 0x6b, 0x53, 0x74, 0x72, 0x65, 0x61, 0x6d, 0x12, 0x10, 0x2e,
	0x70, 0x62, 0x2e, 0x53, 0x74, 0x61, 0x63, 0x6b, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x1a,
	0x0e, 0x2e, 0x70, 0x62, 0x2e, 0x53, 0x74, 0x61, 0x63, 0x6b, 0x53, 0x74, 0x61, 0x74, 0x65, 0x22,
	0x00, 0x30, 0x01, 0x42, 0x13, 0x5a, 0x11, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2e, 0x63, 0x6f,
	0x6d, 0x2f, 0x64, 0x75, 0x6f, 0x2f, 0x70, 0x62, 0x62, 0x06, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x33,
}

var file_duo_service_proto_goTypes = []interface{}{
	(*RegisterRequest)(nil),          // 0: pb.RegisterRequest
	(*LoginRequest)(nil),             // 1: pb.LoginRequest
	(*LoginChallengeResponse)(nil),   // 2: pb.LoginChallengeResponse
	(*FriendRequestRequest)(nil),     // 3: pb.FriendRequestRequest
	(*FriendRequestResponse)(nil),    // 4: pb.FriendRequestResponse
	(*TokenOnlyRequest)(nil),         // 5: pb.TokenOnlyRequest
	(*DeleteFriendRequest)(nil),      // 6: pb.DeleteFriendRequest
	(*StatusChangeRequest)(nil),      // 7: pb.StatusChangeRequest
	(*CreateLobbyRequest)(nil),       // 8: pb.CreateLobbyRequest
	(*ChangeStackDeviceRequest)(nil), // 9: pb.ChangeStackDeviceRequest
	(*JoinLobbyRequest)(nil),         // 10: pb.JoinLobbyRequest
	(*DisconnectLobbyRequest)(nil),   // 11: pb.DisconnectLobbyRequest
	(*GetGameStateRequest)(nil),      // 12: pb.GetGameStateRequest
	(*PlayerAction)(nil),             // 13: pb.PlayerAction
	(*StackRequest)(nil),             // 14: pb.StackRequest
	(*RegisterResponse)(nil),         // 15: pb.RegisterResponse
	(*LoginChallengeRequest)(nil),    // 16: pb.LoginChallengeRequest
	(*LoginResponse)(nil),            // 17: pb.LoginResponse
	(*Void)(nil),                     // 18: pb.void
	(*FriendRequestList)(nil),        // 19: pb.FriendRequestList
	(*FriendList)(nil),               // 20: pb.FriendList
	(*Notification)(nil),             // 21: pb.Notification
	(*LobbyStatus)(nil),              // 22: pb.LobbyStatus
	(*DisconnectLobbyResponse)(nil),  // 23: pb.DisconnectLobbyResponse
	(*GameState)(nil),                // 24: pb.GameState
	(*PlayerState)(nil),              // 25: pb.PlayerState
	(*StackState)(nil),               // 26: pb.StackState
}
var file_duo_service_proto_depIdxs = []int32{
	0,  // 0: pb.DUOService.Register:input_type -> pb.RegisterRequest
	1,  // 1: pb.DUOService.RequestLoginChallenge:input_type -> pb.LoginRequest
	2,  // 2: pb.DUOService.SubmitLoginChallenge:input_type -> pb.LoginChallengeResponse
	3,  // 3: pb.DUOService.SendFriendRequest:input_type -> pb.FriendRequestRequest
	4,  // 4: pb.DUOService.SendFriendRequestResponse:input_type -> pb.FriendRequestResponse
	5,  // 5: pb.DUOService.GetFriendRequests:input_type -> pb.TokenOnlyRequest
	5,  // 6: pb.DUOService.GetFriendList:input_type -> pb.TokenOnlyRequest
	6,  // 7: pb.DUOService.DeleteFriend:input_type -> pb.DeleteFriendRequest
	7,  // 8: pb.DUOService.StatusChangeStream:input_type -> pb.StatusChangeRequest
	5,  // 9: pb.DUOService.GetNotificationStream:input_type -> pb.TokenOnlyRequest
	8,  // 10: pb.DUOService.CreateLobby:input_type -> pb.CreateLobbyRequest
	9,  // 11: pb.DUOService.ChangeStackDevice:input_type -> pb.ChangeStackDeviceRequest
	10, // 12: pb.DUOService.JoinLobby:input_type -> pb.JoinLobbyRequest
	11, // 13: pb.DUOService.DisconnectLobby:input_type -> pb.DisconnectLobbyRequest
	5,  // 14: pb.DUOService.StartGame:input_type -> pb.TokenOnlyRequest
	12, // 15: pb.DUOService.GetGameState:input_type -> pb.GetGameStateRequest
	13, // 16: pb.DUOService.GetPlayerStream:input_type -> pb.PlayerAction
	14, // 17: pb.DUOService.GetStackStream:input_type -> pb.StackRequest
	15, // 18: pb.DUOService.Register:output_type -> pb.RegisterResponse
	16, // 19: pb.DUOService.RequestLoginChallenge:output_type -> pb.LoginChallengeRequest
	17, // 20: pb.DUOService.SubmitLoginChallenge:output_type -> pb.LoginResponse
	18, // 21: pb.DUOService.SendFriendRequest:output_type -> pb.void
	18, // 22: pb.DUOService.SendFriendRequestResponse:output_type -> pb.void
	19, // 23: pb.DUOService.GetFriendRequests:output_type -> pb.FriendRequestList
	20, // 24: pb.DUOService.GetFriendList:output_type -> pb.FriendList
	18, // 25: pb.DUOService.DeleteFriend:output_type -> pb.void
	18, // 26: pb.DUOService.StatusChangeStream:output_type -> pb.void
	21, // 27: pb.DUOService.GetNotificationStream:output_type -> pb.Notification
	22, // 28: pb.DUOService.CreateLobby:output_type -> pb.LobbyStatus
	18, // 29: pb.DUOService.ChangeStackDevice:output_type -> pb.void
	22, // 30: pb.DUOService.JoinLobby:output_type -> pb.LobbyStatus
	23, // 31: pb.DUOService.DisconnectLobby:output_type -> pb.DisconnectLobbyResponse
	18, // 32: pb.DUOService.StartGame:output_type -> pb.void
	24, // 33: pb.DUOService.GetGameState:output_type -> pb.GameState
	25, // 34: pb.DUOService.GetPlayerStream:output_type -> pb.PlayerState
	26, // 35: pb.DUOService.GetStackStream:output_type -> pb.StackState
	18, // [18:36] is the sub-list for method output_type
	0,  // [0:18] is the sub-list for method input_type
	0,  // [0:0] is the sub-list for extension type_name
	0,  // [0:0] is the sub-list for extension extendee
	0,  // [0:0] is the sub-list for field type_name
}

func init() { file_duo_service_proto_init() }
func file_duo_service_proto_init() {
	if File_duo_service_proto != nil {
		return
	}
	file_game_proto_init()
	file_void_proto_init()
	file_auth_messages_proto_init()
	file_lobby_proto_init()
	file_user_state_proto_init()
	file_friend_proto_init()
	file_notification_proto_init()
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: file_duo_service_proto_rawDesc,
			NumEnums:      0,
			NumMessages:   0,
			NumExtensions: 0,
			NumServices:   1,
		},
		GoTypes:           file_duo_service_proto_goTypes,
		DependencyIndexes: file_duo_service_proto_depIdxs,
	}.Build()
	File_duo_service_proto = out.File
	file_duo_service_proto_rawDesc = nil
	file_duo_service_proto_goTypes = nil
	file_duo_service_proto_depIdxs = nil
}
