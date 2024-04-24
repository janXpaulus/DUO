// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.28.1
// 	protoc        v3.21.12
// source: lobby.proto

package pb

import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

type LobbyStatus struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Users      []*User `protobuf:"bytes,1,rep,name=users,proto3" json:"users,omitempty"`
	IsStarting bool    `protobuf:"varint,2,opt,name=isStarting,proto3" json:"isStarting,omitempty"`
	LobbyId    int32   `protobuf:"varint,3,opt,name=lobby_id,json=lobbyId,proto3" json:"lobby_id,omitempty"`
	MaxPlayers int32   `protobuf:"varint,4,opt,name=max_players,json=maxPlayers,proto3" json:"max_players,omitempty"`
}

func (x *LobbyStatus) Reset() {
	*x = LobbyStatus{}
	if protoimpl.UnsafeEnabled {
		mi := &file_lobby_proto_msgTypes[0]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *LobbyStatus) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*LobbyStatus) ProtoMessage() {}

func (x *LobbyStatus) ProtoReflect() protoreflect.Message {
	mi := &file_lobby_proto_msgTypes[0]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use LobbyStatus.ProtoReflect.Descriptor instead.
func (*LobbyStatus) Descriptor() ([]byte, []int) {
	return file_lobby_proto_rawDescGZIP(), []int{0}
}

func (x *LobbyStatus) GetUsers() []*User {
	if x != nil {
		return x.Users
	}
	return nil
}

func (x *LobbyStatus) GetIsStarting() bool {
	if x != nil {
		return x.IsStarting
	}
	return false
}

func (x *LobbyStatus) GetLobbyId() int32 {
	if x != nil {
		return x.LobbyId
	}
	return 0
}

func (x *LobbyStatus) GetMaxPlayers() int32 {
	if x != nil {
		return x.MaxPlayers
	}
	return 0
}

type CreateLobbyRequest struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Token      string `protobuf:"bytes,1,opt,name=token,proto3" json:"token,omitempty"`
	MaxPlayers int32  `protobuf:"varint,2,opt,name=max_players,json=maxPlayers,proto3" json:"max_players,omitempty"`
}

func (x *CreateLobbyRequest) Reset() {
	*x = CreateLobbyRequest{}
	if protoimpl.UnsafeEnabled {
		mi := &file_lobby_proto_msgTypes[1]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *CreateLobbyRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*CreateLobbyRequest) ProtoMessage() {}

func (x *CreateLobbyRequest) ProtoReflect() protoreflect.Message {
	mi := &file_lobby_proto_msgTypes[1]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use CreateLobbyRequest.ProtoReflect.Descriptor instead.
func (*CreateLobbyRequest) Descriptor() ([]byte, []int) {
	return file_lobby_proto_rawDescGZIP(), []int{1}
}

func (x *CreateLobbyRequest) GetToken() string {
	if x != nil {
		return x.Token
	}
	return ""
}

func (x *CreateLobbyRequest) GetMaxPlayers() int32 {
	if x != nil {
		return x.MaxPlayers
	}
	return 0
}

type JoinLobbyRequest struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Token   string `protobuf:"bytes,1,opt,name=token,proto3" json:"token,omitempty"`
	LobbyId int32  `protobuf:"varint,2,opt,name=lobby_id,json=lobbyId,proto3" json:"lobby_id,omitempty"`
}

func (x *JoinLobbyRequest) Reset() {
	*x = JoinLobbyRequest{}
	if protoimpl.UnsafeEnabled {
		mi := &file_lobby_proto_msgTypes[2]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *JoinLobbyRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*JoinLobbyRequest) ProtoMessage() {}

func (x *JoinLobbyRequest) ProtoReflect() protoreflect.Message {
	mi := &file_lobby_proto_msgTypes[2]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use JoinLobbyRequest.ProtoReflect.Descriptor instead.
func (*JoinLobbyRequest) Descriptor() ([]byte, []int) {
	return file_lobby_proto_rawDescGZIP(), []int{2}
}

func (x *JoinLobbyRequest) GetToken() string {
	if x != nil {
		return x.Token
	}
	return ""
}

func (x *JoinLobbyRequest) GetLobbyId() int32 {
	if x != nil {
		return x.LobbyId
	}
	return 0
}

type DisconnectLobbyRequest struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Token   string `protobuf:"bytes,1,opt,name=token,proto3" json:"token,omitempty"`
	LobbyId int32  `protobuf:"varint,2,opt,name=lobby_id,json=lobbyId,proto3" json:"lobby_id,omitempty"`
}

func (x *DisconnectLobbyRequest) Reset() {
	*x = DisconnectLobbyRequest{}
	if protoimpl.UnsafeEnabled {
		mi := &file_lobby_proto_msgTypes[3]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *DisconnectLobbyRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*DisconnectLobbyRequest) ProtoMessage() {}

func (x *DisconnectLobbyRequest) ProtoReflect() protoreflect.Message {
	mi := &file_lobby_proto_msgTypes[3]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use DisconnectLobbyRequest.ProtoReflect.Descriptor instead.
func (*DisconnectLobbyRequest) Descriptor() ([]byte, []int) {
	return file_lobby_proto_rawDescGZIP(), []int{3}
}

func (x *DisconnectLobbyRequest) GetToken() string {
	if x != nil {
		return x.Token
	}
	return ""
}

func (x *DisconnectLobbyRequest) GetLobbyId() int32 {
	if x != nil {
		return x.LobbyId
	}
	return 0
}

type DisconnectLobbyResponse struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Success bool `protobuf:"varint,1,opt,name=success,proto3" json:"success,omitempty"`
}

func (x *DisconnectLobbyResponse) Reset() {
	*x = DisconnectLobbyResponse{}
	if protoimpl.UnsafeEnabled {
		mi := &file_lobby_proto_msgTypes[4]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *DisconnectLobbyResponse) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*DisconnectLobbyResponse) ProtoMessage() {}

func (x *DisconnectLobbyResponse) ProtoReflect() protoreflect.Message {
	mi := &file_lobby_proto_msgTypes[4]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use DisconnectLobbyResponse.ProtoReflect.Descriptor instead.
func (*DisconnectLobbyResponse) Descriptor() ([]byte, []int) {
	return file_lobby_proto_rawDescGZIP(), []int{4}
}

func (x *DisconnectLobbyResponse) GetSuccess() bool {
	if x != nil {
		return x.Success
	}
	return false
}

var File_lobby_proto protoreflect.FileDescriptor

var file_lobby_proto_rawDesc = []byte{
	0x0a, 0x0b, 0x6c, 0x6f, 0x62, 0x62, 0x79, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x12, 0x02, 0x70,
	0x62, 0x1a, 0x0a, 0x75, 0x73, 0x65, 0x72, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x22, 0x8b, 0x01,
	0x0a, 0x0b, 0x4c, 0x6f, 0x62, 0x62, 0x79, 0x53, 0x74, 0x61, 0x74, 0x75, 0x73, 0x12, 0x20, 0x0a,
	0x05, 0x75, 0x73, 0x65, 0x72, 0x73, 0x18, 0x01, 0x20, 0x03, 0x28, 0x0b, 0x32, 0x0a, 0x2e, 0x75,
	0x73, 0x65, 0x72, 0x2e, 0x55, 0x73, 0x65, 0x72, 0x52, 0x05, 0x75, 0x73, 0x65, 0x72, 0x73, 0x12,
	0x1e, 0x0a, 0x0a, 0x69, 0x73, 0x53, 0x74, 0x61, 0x72, 0x74, 0x69, 0x6e, 0x67, 0x18, 0x02, 0x20,
	0x01, 0x28, 0x08, 0x52, 0x0a, 0x69, 0x73, 0x53, 0x74, 0x61, 0x72, 0x74, 0x69, 0x6e, 0x67, 0x12,
	0x19, 0x0a, 0x08, 0x6c, 0x6f, 0x62, 0x62, 0x79, 0x5f, 0x69, 0x64, 0x18, 0x03, 0x20, 0x01, 0x28,
	0x05, 0x52, 0x07, 0x6c, 0x6f, 0x62, 0x62, 0x79, 0x49, 0x64, 0x12, 0x1f, 0x0a, 0x0b, 0x6d, 0x61,
	0x78, 0x5f, 0x70, 0x6c, 0x61, 0x79, 0x65, 0x72, 0x73, 0x18, 0x04, 0x20, 0x01, 0x28, 0x05, 0x52,
	0x0a, 0x6d, 0x61, 0x78, 0x50, 0x6c, 0x61, 0x79, 0x65, 0x72, 0x73, 0x22, 0x4b, 0x0a, 0x12, 0x43,
	0x72, 0x65, 0x61, 0x74, 0x65, 0x4c, 0x6f, 0x62, 0x62, 0x79, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73,
	0x74, 0x12, 0x14, 0x0a, 0x05, 0x74, 0x6f, 0x6b, 0x65, 0x6e, 0x18, 0x01, 0x20, 0x01, 0x28, 0x09,
	0x52, 0x05, 0x74, 0x6f, 0x6b, 0x65, 0x6e, 0x12, 0x1f, 0x0a, 0x0b, 0x6d, 0x61, 0x78, 0x5f, 0x70,
	0x6c, 0x61, 0x79, 0x65, 0x72, 0x73, 0x18, 0x02, 0x20, 0x01, 0x28, 0x05, 0x52, 0x0a, 0x6d, 0x61,
	0x78, 0x50, 0x6c, 0x61, 0x79, 0x65, 0x72, 0x73, 0x22, 0x43, 0x0a, 0x10, 0x4a, 0x6f, 0x69, 0x6e,
	0x4c, 0x6f, 0x62, 0x62, 0x79, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x12, 0x14, 0x0a, 0x05,
	0x74, 0x6f, 0x6b, 0x65, 0x6e, 0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x05, 0x74, 0x6f, 0x6b,
	0x65, 0x6e, 0x12, 0x19, 0x0a, 0x08, 0x6c, 0x6f, 0x62, 0x62, 0x79, 0x5f, 0x69, 0x64, 0x18, 0x02,
	0x20, 0x01, 0x28, 0x05, 0x52, 0x07, 0x6c, 0x6f, 0x62, 0x62, 0x79, 0x49, 0x64, 0x22, 0x49, 0x0a,
	0x16, 0x44, 0x69, 0x73, 0x63, 0x6f, 0x6e, 0x6e, 0x65, 0x63, 0x74, 0x4c, 0x6f, 0x62, 0x62, 0x79,
	0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x12, 0x14, 0x0a, 0x05, 0x74, 0x6f, 0x6b, 0x65, 0x6e,
	0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x05, 0x74, 0x6f, 0x6b, 0x65, 0x6e, 0x12, 0x19, 0x0a,
	0x08, 0x6c, 0x6f, 0x62, 0x62, 0x79, 0x5f, 0x69, 0x64, 0x18, 0x02, 0x20, 0x01, 0x28, 0x05, 0x52,
	0x07, 0x6c, 0x6f, 0x62, 0x62, 0x79, 0x49, 0x64, 0x22, 0x33, 0x0a, 0x17, 0x44, 0x69, 0x73, 0x63,
	0x6f, 0x6e, 0x6e, 0x65, 0x63, 0x74, 0x4c, 0x6f, 0x62, 0x62, 0x79, 0x52, 0x65, 0x73, 0x70, 0x6f,
	0x6e, 0x73, 0x65, 0x12, 0x18, 0x0a, 0x07, 0x73, 0x75, 0x63, 0x63, 0x65, 0x73, 0x73, 0x18, 0x01,
	0x20, 0x01, 0x28, 0x08, 0x52, 0x07, 0x73, 0x75, 0x63, 0x63, 0x65, 0x73, 0x73, 0x42, 0x13, 0x5a,
	0x11, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x64, 0x75, 0x6f, 0x2f,
	0x70, 0x62, 0x62, 0x06, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x33,
}

var (
	file_lobby_proto_rawDescOnce sync.Once
	file_lobby_proto_rawDescData = file_lobby_proto_rawDesc
)

func file_lobby_proto_rawDescGZIP() []byte {
	file_lobby_proto_rawDescOnce.Do(func() {
		file_lobby_proto_rawDescData = protoimpl.X.CompressGZIP(file_lobby_proto_rawDescData)
	})
	return file_lobby_proto_rawDescData
}

var file_lobby_proto_msgTypes = make([]protoimpl.MessageInfo, 5)
var file_lobby_proto_goTypes = []interface{}{
	(*LobbyStatus)(nil),             // 0: pb.LobbyStatus
	(*CreateLobbyRequest)(nil),      // 1: pb.CreateLobbyRequest
	(*JoinLobbyRequest)(nil),        // 2: pb.JoinLobbyRequest
	(*DisconnectLobbyRequest)(nil),  // 3: pb.DisconnectLobbyRequest
	(*DisconnectLobbyResponse)(nil), // 4: pb.DisconnectLobbyResponse
	(*User)(nil),                    // 5: user.User
}
var file_lobby_proto_depIdxs = []int32{
	5, // 0: pb.LobbyStatus.users:type_name -> user.User
	1, // [1:1] is the sub-list for method output_type
	1, // [1:1] is the sub-list for method input_type
	1, // [1:1] is the sub-list for extension type_name
	1, // [1:1] is the sub-list for extension extendee
	0, // [0:1] is the sub-list for field type_name
}

func init() { file_lobby_proto_init() }
func file_lobby_proto_init() {
	if File_lobby_proto != nil {
		return
	}
	file_user_proto_init()
	if !protoimpl.UnsafeEnabled {
		file_lobby_proto_msgTypes[0].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*LobbyStatus); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_lobby_proto_msgTypes[1].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*CreateLobbyRequest); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_lobby_proto_msgTypes[2].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*JoinLobbyRequest); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_lobby_proto_msgTypes[3].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*DisconnectLobbyRequest); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_lobby_proto_msgTypes[4].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*DisconnectLobbyResponse); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: file_lobby_proto_rawDesc,
			NumEnums:      0,
			NumMessages:   5,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_lobby_proto_goTypes,
		DependencyIndexes: file_lobby_proto_depIdxs,
		MessageInfos:      file_lobby_proto_msgTypes,
	}.Build()
	File_lobby_proto = out.File
	file_lobby_proto_rawDesc = nil
	file_lobby_proto_goTypes = nil
	file_lobby_proto_depIdxs = nil
}
