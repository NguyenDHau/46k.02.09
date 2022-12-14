CREATE DATABASE QuanLyBanHang_NamNhac
Use QuanLyBanHang_NamNhac
go

create table Cap_Nhat_Kho
(
	Ngay date,
	MaHang varchar(5),
	TenHang nvarchar(100),
	TinhTrang nvarchar(20),
	SoLuong int,
	DonGia numeric (12,0),
	DonViTinh nvarchar(20),
	DoanhThu numeric (12,0),
	PRIMARY KEY (MaHang)
)
go

create table Kho
(
	MaHang varchar(5),
	TenHang nvarchar(100),
	GiaBan numeric (12,0),
	SoLuongTon int,
	PRIMARY KEY (MaHang),
	foreign key (MaHang) references Cap_Nhat_Kho
)
go

create table DonBan
(
    MaDonBan int,
    HoTen nvarchar(100),
    SoDT varchar(10),
	MaHang varchar(5),
    TenHang nvarchar(100),
	SoLuong int,
	ThanhTien numeric(12,0),
    ThoiGian date,
    TrangThai varchar(20),
    primary key (MaDonBan),
    foreign key (MaHang) references Kho,
)
go

Create table KhachHang(
	MaKhachHang varchar(5),
	MaDonBan int,
	HoTen nvarchar(100),
	SoDR varchar(10),
	TrangThai varchar(20)
	primary key (MaKhachHang),
	foreign key (MaDonBan) references DonBan
)

create table KhachHang_Chua_Thanh_Toan
(
	MaKhachHang varchar(5),
	MaHoaDon int,
	SoDT varchar(10),
	SoTien numeric(12,0),
	primary key(MaKhachHang),
	foreign key (MaKhachHang) references KhachHang
)
go

--Cap_Nhat_Kho
CREATE TRIGGER TRIG_XuatNhap_Kho
on Cap_Nhat_Kho
instead of insert
AS
BEGIN
    DECLARE @Ngay date,
            @TenHang nvarchar(100),
            @TinhTrang nvarchar(20),
            @SoLuong int,
            @DonGia numeric (12,0),
            @DoanhThu numeric (12,0),
            @MaHang varchar(5),
            @MaHang_new varchar(5),
            @DonViTinh nvarchar(20)
    select @TenHang = TenHang,
           @SoLuong = SoLuong,
           @DonGia = DonGia,
           @Ngay = Ngay,
           @TinhTrang = TinhTrang,
           @DoanhThu = DoanhThu,
           @MaHang = MaHang,
           @DonViTinh = DonViTinh from inserted
    IF exists (select * from inserted)
        BEGIN
            SET @Ngay = getdate()
            Set @DoanhThu = @DonGia * @SoLuong
            if not exists (select MaHang from Cap_Nhat_Kho)
                BEGIN   
                    Set @MaHang_new = '00001'
                End
            Else IF exists (select MaHang from Cap_Nhat_Kho)
                BEGIN
                    SET @TinhTrang = (select TinhTrang from inserted)
                    SET @MaHang = (select max(MaHang) + 1 from Cap_Nhat_Kho )
                    SET @MaHang_new = REPLICATE('0',5 - len (@MaHang)) + @MaHang
                END              
        END
    IF @TenHang in (select TenHang from Cap_Nhat_Kho)
        BEGIN
            IF @TinhTrang = '0'
                BEGIN
                    UPDATE Cap_Nhat_Kho
                    SET Cap_Nhat_Kho.SoLuong = Cap_Nhat_Kho.SoLuong + @SoLuong
                    where @TenHang = Cap_Nhat_Kho.TenHang

                    UPDATE Kho
                    SET Kho.SoLuongTon = Kho.SoLuongTon + @SoLuong
                    where @TenHang = TenHang

                    UPDATE Cap_Nhat_Kho
                    SET DoanhThu = @DonGia * Cap_Nhat_Kho.SoLuong
                    where @TenHang = Cap_Nhat_Kho.TenHang

                    UPDATE Cap_Nhat_Kho
                    SET TinhTrang = N'V???a Nh???p Th??m H??ng'
                    where @TenHang = Cap_Nhat_Kho.TenHang

                END
            ELSE iF @TinhTrang = '1'
                BEGIN
                    UPDATE Cap_Nhat_Kho
                    SET Cap_Nhat_Kho.SoLuong = Cap_Nhat_Kho.SoLuong - @SoLuong
                    where @TenHang = Cap_Nhat_Kho.TenHang
                    
                    UPDATE Kho
                    SET Kho.SoLuongTon = Kho.SoLuongTon - @SoLuong
                    where @TenHang = TenHang

                    UPDATE Cap_Nhat_Kho
                    SET DoanhThu = @DonGia * Cap_Nhat_Kho.SoLuong
                    where @TenHang = Cap_Nhat_Kho.TenHang

                    UPDATE Cap_Nhat_Kho
                    SET TinhTrang = N'V???a Xu???t H??ng'
                    where @TenHang = Cap_Nhat_Kho.TenHang

                END
            return 
        END 
    ELSE 
        BEGIN
            SET @TinhTrang = N'H??ng M???i'
        END

    insert into Cap_Nhat_Kho values (@Ngay,@MaHang_new,@TenHang,@TinhTrang,@SoLuong,@DonGia,@DonViTinh,@DoanhThu)
    insert into Kho values (@MaHang_new,@TenHang,@DonGia,@SoLuong)
END



insert into Cap_Nhat_Kho values(null,null, N'B??a Su','0',20,28000,'c??y',null)
insert into Cap_Nhat_Kho values(null,null, N'B??a t???','0',20,50000,'c??y',null)
insert into Cap_Nhat_Kho values(null,null, N'B??a ??inh','0',20,25000,'c??y',null)
insert into Cap_Nhat_Kho values(null,null, N'??inh th??p 1F','0',20,55000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'??inh th??p 2F','0',20,55000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'??inh th??p 3F','0',20,55000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'??inh th??p 4F','0',20,55000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'??inh th??p 5F','0',20,55000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'V??t ??en 2F','0',20,47000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'V??t ??en 3F','0',20,47000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'V??t ??en 4F','0',20,47000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'V??t ??en 5F','0',20,47000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'V??t ??en 6F','0',20,47000,'kg',null)
insert into Cap_Nhat_Kho values(null,null, N'???ng nh???a b??nh minh 21','0',30,33000,'c??y',null)
insert into Cap_Nhat_Kho values(null,null, N'???ng nh???a b??nh minh 27','0',30,45000,'c??y',null)
insert into Cap_Nhat_Kho values(null,null, N'???ng nh???a b??nh minh 34','0',20,64000,'c??y',null)
insert into Cap_Nhat_Kho values(null,null, N'???ng nh???a b??nh minh 42','0',15,83000,'c??y',null)
insert into Cap_Nhat_Kho values(null,null, N'???ng nh???a b??nh minh 49','0',15,103000,'c??y',null)
insert into Cap_Nhat_Kho values(null,null, N'???ng nh???a b??nh minh 60','0',15,115000,'c??y',null)
insert into Cap_Nhat_Kho values(null,null, N'???ng nh???a b??nh minh 90','0',5,235000,'c??y',null)
insert into Cap_Nhat_Kho values(null,null, N'???ng nh???a b??nh minh 114','0',5,356000,'c??y',null)
insert into Cap_Nhat_Kho values(null,null, N'S??n n?????c','0',50,110000,'lon',null)
insert into Cap_Nhat_Kho values(null,null, N'S??n d???u','0',50,250000,'lon',null)
insert into Cap_Nhat_Kho values(null,null, N'S??n trong nh??','0',10,200000,'th??ng',null)
insert into Cap_Nhat_Kho values(null,null, N'S??n ngo??i tr???i','0',20,110000,'th??ng',null)
insert into Cap_Nhat_Kho values(null,null, N'S??n s???t','0',50,73000,'lon',null)
insert into Cap_Nhat_Kho values(null,null, N'S??n g???','0',50,42000,'lon',null)
insert into Cap_Nhat_Kho values(null,null, N'Qu???t Senko','0',10,240000,'C??y',null)
insert into Cap_Nhat_Kho values(null,null, N'Qu???t Asia','0',10,280000,'C??y',null)
insert into Cap_Nhat_Kho values(null,null, N'Qu???t Panasonic','0',10,400000,'C??y',null)
insert into Cap_Nhat_Kho values(null,null, N'Qu???t Tosiba','0',7,430000,'C??y',null)
insert into Cap_Nhat_Kho values(null,null, N'X??ng th??m','0',100,45000,'l??t',null)
insert into Cap_Nhat_Kho values(null,null, N'L?????i th??p','0',300,12000,'m',null)
insert into Cap_Nhat_Kho values(null,null, N'L?????i nh???a','0',300,12000,'m',null)
insert into Cap_Nhat_Kho values(null,null, N'M??y n??ng l???nh Cento','0',3,2200000,'C??i',null)
insert into Cap_Nhat_Kho values(null,null, N'M??y n??ng l???nh Panasonic','0',5,3300000,'C??i',null)
insert into Cap_Nhat_Kho values(null,null, N'M??y n??ng l???nh Tosiba','0',2,3700000,'C??i',null)
insert into Cap_Nhat_Kho values(null,null, N'Xe r??a','0',4,330000,'Chi???c',null)
insert into Cap_Nhat_Kho values(null,null, N'??? ??i???n','0',50,80000,'C??i',null)
insert into Cap_Nhat_Kho values(null,null, N'Ph??ch c???m','0',50,12000,'C??i',null)
insert into Cap_Nhat_Kho values(null,null, N'D??y ??i???n','0',500,10000,'m',null)
insert into Cap_Nhat_Kho values(null,null, N'Xi m??ng','0',10,280000,'Bao',null)
insert into Cap_Nhat_Kho values(null,null, N'D??y th??p','0',600,20000,'Kg',null)
insert into Cap_Nhat_Kho values(null,null, N'X???ng','0',15,100000,'C??i',null)
insert into Cap_Nhat_Kho values(null,null, N'Cu???c','0',10,100000,'C??i',null)
go


select * from Cap_Nhat_Kho


create nonclustered index MaHang on Cap_Nhat_Kho(MaHang)

